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
enum SubscriptionTier: String, Codable {
    case free = "free"
    case pro = "pro"
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
    var photoNames: [String]
    var subscriptionTier: SubscriptionTier = .free
    
    init(
        id: UUID = UUID(),
        displayName: String,
        email: String,
        role: String,
        experienceYears: Int,
        sector: Sector,
        bio: String,
        lookingFor: LookingFor,
        city: String,
        isRemote: Bool,
        techStack: [String],
        photoNames: [String],
        subscriptionTier: SubscriptionTier = .free
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.role = role
        self.experienceYears = experienceYears
        self.sector = sector
        self.bio = bio
        self.lookingFor = lookingFor
        self.city = city
        self.isRemote = isRemote
        self.techStack = techStack
        self.photoNames = photoNames
        self.subscriptionTier = subscriptionTier
    }
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
