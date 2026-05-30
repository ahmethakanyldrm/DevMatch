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
    
    @Published var isRealAPIMode: Bool = false
    
    init() {
        // Initialize current user (mock backend developer)
        self.currentUser = DeveloperProfile(
            displayName: "Ahmet Hakan Yıldırım",
            email: "ahmet@techconnect.com",
            role: "iOS Geliştirici",
            experienceYears: 4,
            sector: .startup,
            bio: "SwiftUI, Combine ve Java Spring Boot ile full-stack mobil uygulamalar geliştiriyorum. Yeni insanlarla tanışmak ve projeler üzerine kahve eşliğinde sohbet etmek harika olur!",
            lookingFor: .collaboration,
            city: "İstanbul",
            isRemote: true,
            techStack: ["Swift", "SwiftUI", "Java", "Spring Boot", "PostgreSQL", "Git"],
            photoNames: ["person.fill"]
        )
        
        setupMockProfiles()
        setupMockMatchesAndMessages()
        
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
                self.isRealAPIMode = true
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
            await MainActor.run {
                self.isRealAPIMode = false
            }
        }
    }
    
    func fetchDiscoverDeck() async {
        guard isRealAPIMode else { return }
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
        guard isRealAPIMode else { return }
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
    
    private func setupMockProfiles() {
        self.profiles = [
            DeveloperProfile(
                displayName: "Merve Yılmaz",
                email: "merve@startup.io",
                role: "Senior iOS Developer",
                experienceYears: 6,
                sector: .startup,
                bio: "7 yıldır Swift ile mobil uygulamalar geliştiriyorum. Clean Architecture, MVVM ve SwiftUI odak noktalarım. Tecrübelerimi paylaşmak için Mentee'ler arıyorum.",
                lookingFor: .mentor,
                city: "Ankara",
                isRemote: true,
                techStack: ["Swift", "SwiftUI", "Combine", "UIKit", "Git", "CI/CD"],
                photoNames: ["person.crop.circle.badge.checkmark"]
            ),
            DeveloperProfile(
                displayName: "Can Demir",
                email: "can@corporate.com",
                role: "Backend Architect",
                experienceYears: 8,
                sector: .corporate,
                bio: "Java, Spring Cloud ve Kubernetes ile yüksek ölçekli mikroservis mimarileri tasarlıyorum. İstanbul içi kahve sohbetlerine her zaman açığım.",
                lookingFor: .coffeeChat,
                city: "İstanbul",
                isRemote: false,
                techStack: ["Java", "Spring Boot", "Docker", "Kubernetes", "PostgreSQL", "Kafka"],
                photoNames: ["person.crop.square.fill"]
            ),
            DeveloperProfile(
                displayName: "Elif Kaya",
                email: "elif@freelance.net",
                role: "UI/UX Designer",
                experienceYears: 3,
                sector: .freelance,
                bio: "Figma ve Adobe XD ile mobil arayüz tasarımları yapıyorum. Yazılımcılarla ortak mobil projelerde (Side Project) iş birliği yapmak istiyorum.",
                lookingFor: .collaboration,
                city: "İzmir",
                isRemote: true,
                techStack: ["Figma", "Sketch", "HTML", "CSS", "UI Design"],
                photoNames: ["person.crop.circle.fill"]
            ),
            DeveloperProfile(
                displayName: "Oğuzhan Çelik",
                email: "oguzhan@tech.com",
                role: "Junior Spring Boot Developer",
                experienceYears: 1,
                sector: .startup,
                bio: "Yeni mezunum, backend alanında kendimi geliştirmeye çalışıyorum. Spring Boot ve Hibernate öğreniyorum. Bana yol gösterecek bir Mentör arıyorum.",
                lookingFor: .mentee,
                city: "İstanbul",
                isRemote: false,
                techStack: ["Java", "Spring Boot", "PostgreSQL", "Git", "Maven"],
                photoNames: ["person.fill.viewfinder"]
            ),
            DeveloperProfile(
                displayName: "Zeynep Şahin",
                email: "zeynep@agile.org",
                role: "Product Manager",
                experienceYears: 5,
                sector: .corporate,
                bio: "Agile ürün yönetimi, kullanıcı araştırmaları ve MVP planlama konularında uzmanım. Teknik ekiplerle doğru iletişim kurmak ve yeni networkler edinmek istiyorum.",
                lookingFor: .coffeeChat,
                city: "İstanbul",
                isRemote: true,
                techStack: ["Jira", "Figma", "Agile", "Product Strategy"],
                photoNames: ["person.crop.square.fill.and.at.rectangle"]
            )
        ]
    }
    
    private func setupMockMatchesAndMessages() {
        let match1Profile = DeveloperProfile(
            displayName: "Merve Yılmaz",
            email: "merve@startup.io",
            role: "Senior iOS Developer",
            experienceYears: 6,
            sector: .startup,
            bio: "7 yıldır Swift ile mobil uygulamalar geliştiriyorum. Clean Architecture, MVVM ve SwiftUI odak noktalarım. Tecrübelerimi paylaşmak için Mentee'ler arıyorum.",
            lookingFor: .mentor,
            city: "Ankara",
            isRemote: true,
            techStack: ["Swift", "SwiftUI", "Combine", "UIKit", "Git", "CI/CD"],
            photoNames: ["person.crop.circle.badge.checkmark"]
        )
        
        let match2Profile = DeveloperProfile(
            displayName: "Elif Kaya",
            email: "elif@freelance.net",
            role: "UI/UX Designer",
            experienceYears: 3,
            sector: .freelance,
            bio: "Figma ve Adobe XD ile mobil arayüz tasarımları yapıyorum. Yazılımcılarla ortak mobil projelerde (Side Project) iş birliği yapmak istiyorum.",
            lookingFor: .collaboration,
            city: "İzmir",
            isRemote: true,
            techStack: ["Figma", "Sketch", "HTML", "CSS", "UI Design"],
            photoNames: ["person.crop.circle.fill"]
        )
        
        let match1Id = UUID()
        let match2Id = UUID()
        
        let match1 = Match(id: match1Id, profile: match1Profile, matchedAt: Date().addingTimeInterval(-86400), lastMessage: "SwiftUI hakkında sorduğun soruya detaylı bakacağım.")
        let match2 = Match(id: match2Id, profile: match2Profile, matchedAt: Date().addingTimeInterval(-3600), lastMessage: "Proje iş birliği için harika bir fikir, konuşalım.")
        
        self.matches = [match1, match2]
        
        self.messagesByMatch[match1Id] = [
            Message(senderId: match1Profile.id, content: "Merhaba Ahmet Hakan! SwiftUI projen gerçekten çok temiz görünüyor.", sentAt: Date().addingTimeInterval(-86000), isRead: true),
            Message(senderId: currentUser.id, content: "Çok teşekkürler Merve! Sizin deneyimlerinizden faydalanmak harika olur.", sentAt: Date().addingTimeInterval(-85000), isRead: true),
            Message(senderId: match1Profile.id, content: "SwiftUI hakkında sorduğun soruya detaylı bakacağım.", sentAt: Date().addingTimeInterval(-84000), isRead: true)
        ]
        
        self.messagesByMatch[match2Id] = [
            Message(senderId: currentUser.id, content: "Selam Elif, tasarımlarını inceledim, TechConnect projesi için bir UI/UX desteği arıyorum.", sentAt: Date().addingTimeInterval(-3000), isRead: true),
            Message(senderId: match2Profile.id, content: "Proje iş birliği için harika bir fikir, konuşalım.", sentAt: Date().addingTimeInterval(-2000), isRead: false)
        ]
    }
    
    func sendMessage(matchId: UUID, content: String) {
        if isRealAPIMode {
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
        } else {
            let newMessage = Message(senderId: currentUser.id, content: content, sentAt: Date(), isRead: false)
            if var list = messagesByMatch[matchId] {
                list.append(newMessage)
                messagesByMatch[matchId] = list
            } else {
                messagesByMatch[matchId] = [newMessage]
            }
            if let index = matches.firstIndex(where: { $0.id == matchId }) {
                matches[index].lastMessage = content
            }
        }
    }
    
    func swipe(profile: DeveloperProfile, isLike: Bool) async -> Bool {
        if isRealAPIMode {
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
        } else {
            return isLike && Double.random(in: 0...1) > 0.4
        }
    }
    
    func requestCoffeeChat(matchId: UUID, proposedTime: Date) {
        if isRealAPIMode {
            Task {
                do {
                    let _ = try await APIService.shared.proposeCoffeeChat(matchId: matchId, proposedTime: proposedTime)
                    // Optionally update coffee chat list
                } catch {
                    print("Failed to propose real coffee chat: \(error.localizedDescription)")
                }
            }
        } else {
            let req = CoffeeChatRequest(
                id: UUID(),
                matchId: matchId,
                requesterId: currentUser.id,
                proposedTime: proposedTime,
                status: .pending
            )
            coffeeChatRequests.append(req)
        }
    }
    
    func saveProfile(profile: DeveloperProfile) async throws {
        if isRealAPIMode {
            let updated = try await APIService.shared.updateMyProfile(profile: profile)
            await MainActor.run {
                self.currentUser = updated
            }
        } else {
            await MainActor.run {
                self.currentUser = profile
            }
        }
    }
    
    func logout() {
        APIService.shared.clearToken()
        isRealAPIMode = false
        self.currentUser = DeveloperProfile(
            displayName: "Ahmet Hakan Yıldırım",
            email: "ahmet@techconnect.com",
            role: "iOS Geliştirici",
            experienceYears: 4,
            sector: .startup,
            bio: "SwiftUI, Combine ve Java Spring Boot ile full-stack mobil uygulamalar geliştiriyorum. Yeni insanlarla tanışmak ve projeler üzerine kahve eşliğinde sohbet etmek harika olur!",
            lookingFor: .collaboration,
            city: "İstanbul",
            isRemote: true,
            techStack: ["Swift", "SwiftUI", "Java", "Spring Boot", "PostgreSQL", "Git"],
            photoNames: ["person.fill"]
        )
        setupMockProfiles()
        setupMockMatchesAndMessages()
    }
}
