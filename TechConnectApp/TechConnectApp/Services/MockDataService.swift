import Foundation
import Combine

class MockDataService: ObservableObject {
    static let shared = MockDataService()
    
    @Published var currentUser: DeveloperProfile
    @Published var profiles: [DeveloperProfile] = []
    @Published var matches: [Match] = []
    @Published var messagesByMatch: [UUID: [Message]] = [:]
    @Published var coffeeChatRequests: [CoffeeChatRequest] = []
    @Published var appTheme: AppTheme = .system
    @Published var appLanguage: AppLanguage = AppLanguage.defaultLanguage()
    
    init() {
        // Initialize current user with placeholder details
        self.currentUser = DeveloperProfile(
            displayName: "",
            email: "",
            role: "",
            experienceYears: 0,
            sector: .startup,
            bio: "",
            lookingFor: .coffeeChat,
            city: "",
            isRemote: false,
            techStack: [],
            photoNames: []
        )
        
        // Auto load real backend data if token is active
        if APIService.shared.isLoggedIn {
            Task {
                await fetchAllData()
            }
        }
    }
    
    func fetchAllData() async {
        do {
            let profile = try await APIService.shared.getMyProfile()
            let deck = try await APIService.shared.getDiscoverDeck()
            let matchesList = try await APIService.shared.getMatches()
            
            await MainActor.run {
                self.currentUser = profile
                self.profiles = deck
                self.matches = matchesList
            }
            
            for match in matchesList {
                if let msgs = try? await APIService.shared.getMessages(matchId: match.id) {
                    await MainActor.run {
                        self.messagesByMatch[match.id] = msgs
                    }
                }
            }
        } catch {
            print("Error loading data from API: \(error.localizedDescription)")
        }
    }
    
    func fetchDiscoverDeck() async {
        do {
            let deck = try await APIService.shared.getDiscoverDeck()
            await MainActor.run {
                self.profiles = deck
            }
        } catch {
            print("Error fetching discover deck: \(error.localizedDescription)")
        }
    }
    
    func fetchMatches() async {
        do {
            let matchesList = try await APIService.shared.getMatches()
            await MainActor.run {
                self.matches = matchesList
            }
            for match in matchesList {
                if let msgs = try? await APIService.shared.getMessages(matchId: match.id) {
                    await MainActor.run {
                        self.messagesByMatch[match.id] = msgs
                    }
                }
            }
        } catch {
            print("Error fetching matches: \(error.localizedDescription)")
        }
    }
    
    func calculateCompatibilityScore(target: DeveloperProfile) -> Int {
        var score = 0
        let sharedTech = Set(currentUser.techStack).intersection(Set(target.techStack))
        score += sharedTech.count * 3
        
        if currentUser.sector == target.sector {
            score += 2
        }
        
        if currentUser.lookingFor == target.lookingFor.compatibilityPartner {
            score += 4
        }
        
        if abs(currentUser.experienceYears - target.experienceYears) <= 3 {
            score += 1
        }
        
        return score
    }
    
    func sendMessage(matchId: UUID, content: String) {
        Task {
            do {
                let msg = try await APIService.shared.sendMessage(matchId: matchId, content: content)
                await MainActor.run {
                    if var list = messagesByMatch[matchId] {
                        list.append(msg)
                        messagesByMatch[matchId] = list
                    } else {
                        messagesByMatch[matchId] = [msg]
                    }
                    if let index = matches.firstIndex(where: { $0.id == matchId }) {
                        matches[index].lastMessage = content
                    }
                }
            } catch {
                print("Failed to send real message: \(error.localizedDescription)")
            }
        }
    }
    
    func swipe(profile: DeveloperProfile, isLike: Bool) async -> Bool {
        do {
            let res = try await APIService.shared.swipe(targetId: profile.id, isLike: isLike)
            if res.matched {
                await fetchMatches()
                return true
            }
        } catch {
            print("Error recording real swipe: \(error.localizedDescription)")
        }
        return false
    }
    
    func requestCoffeeChat(matchId: UUID, proposedTime: Date) {
        Task {
            do {
                let _ = try await APIService.shared.proposeCoffeeChat(matchId: matchId, proposedTime: proposedTime)
            } catch {
                print("Failed to propose real coffee chat: \(error.localizedDescription)")
            }
        }
    }
    
    func saveProfile(profile: DeveloperProfile) async throws {
        let updated = try await APIService.shared.updateMyProfile(profile: profile)
        await MainActor.run {
            self.currentUser = updated
        }
    }
    
    func uploadPhoto(image: Data) async throws {
        let updated = try await APIService.shared.uploadPhoto(image: image)
        await MainActor.run {
            self.currentUser = updated
        }
    }
    
    func logout() {
        APIService.shared.clearToken()
        SubscriptionManager.shared.resetUser()
        self.currentUser = DeveloperProfile(
            displayName: "",
            email: "",
            role: "",
            experienceYears: 0,
            sector: .startup,
            bio: "",
            lookingFor: .coffeeChat,
            city: "",
            isRemote: false,
            techStack: [],
            photoNames: []
        )
        self.profiles = []
        self.matches = []
        self.messagesByMatch = [:]
        self.coffeeChatRequests = []
    }
}
