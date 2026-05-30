import Foundation

enum Sector: String, Codable, CaseIterable {
    case startup = "Startup"
    case corporate = "Kurumsal"
    case freelance = "Freelance"
}

enum LookingFor: String, Codable, CaseIterable {
    case mentor = "Mentör"
    case mentee = "Mentee"
    case collaboration = "Proje Ortaklığı"
    case coffeeChat = "Kahve Sohbeti"
    
    var compatibilityPartner: LookingFor {
        switch self {
        case .mentor: return .mentee
        case .mentee: return .mentor
        case .collaboration: return .collaboration
        case .coffeeChat: return .coffeeChat
        }
    }
}

struct DeveloperProfile: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var displayName: String
    var email: String
    var role: String
    var experienceYears: Int
    var sector: Sector
    var bio: String
    var lookingFor: LookingFor
    var city: String
    var isRemote: Bool
    var techStack: [String]
    var photoNames: [String] // System SF symbol names or local mock assets
}

struct Message: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var senderId: UUID
    var content: String
    var sentAt: Date
    var isRead: Bool
}

struct Match: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var profile: DeveloperProfile
    var matchedAt: Date
    var lastMessage: String?
}

struct CoffeeChatRequest: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var matchId: UUID
    var requesterId: UUID
    var proposedTime: Date
    var status: RequestStatus
    
    enum RequestStatus: String, Codable {
        case pending = "Beklemede"
        case accepted = "Kabul Edildi"
        case declined = "Reddedildi"
    }
}
