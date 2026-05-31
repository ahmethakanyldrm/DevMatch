import Foundation
import SwiftUI

enum Sector: String, Codable, CaseIterable {
    case startup = "STARTUP"
    case corporate = "CORPORATE"
    case freelance = "FREELANCE"
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .startup: return "Startup"
        case .corporate: return lang == .turkish ? "Kurumsal" : "Corporate"
        case .freelance: return "Freelance"
        }
    }
}

enum LookingFor: String, Codable, CaseIterable {
    case mentor = "MENTOR"
    case mentee = "MENTEE"
    case collaboration = "COLLABORATION"
    case coffeeChat = "COFFEE_CHAT"
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .mentor: return lang == .turkish ? "Mentör" : "Mentor"
        case .mentee: return lang == .turkish ? "Mentee" : "Mentee"
        case .collaboration: return lang == .turkish ? "Proje Ortaklığı" : "Collaboration"
        case .coffeeChat: return lang == .turkish ? "Kahve Sohbeti" : "Coffee Chat"
        }
    }
    
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
    case free = "FREE"
    case pro = "PRO"
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
    var githubUsername: String?
    var compatibilityScore: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, displayName, email, role, experienceYears, sector, bio, lookingFor, city, isRemote, techStack, photoNames, subscriptionTier, githubUsername, compatibilityScore
    }
    
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
        subscriptionTier: SubscriptionTier = .free,
        githubUsername: String? = nil,
        compatibilityScore: Int? = nil
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
        self.githubUsername = githubUsername
        self.compatibilityScore = compatibilityScore
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.role = try container.decodeIfPresent(String.self, forKey: .role) ?? ""
        self.experienceYears = try container.decodeIfPresent(Int.self, forKey: .experienceYears) ?? 0
        self.sector = try container.decodeIfPresent(Sector.self, forKey: .sector) ?? .startup
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        self.lookingFor = try container.decodeIfPresent(LookingFor.self, forKey: .lookingFor) ?? .collaboration
        self.city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        self.isRemote = try container.decodeIfPresent(Bool.self, forKey: .isRemote) ?? false
        self.techStack = try container.decodeIfPresent([String].self, forKey: .techStack) ?? []
        self.photoNames = try container.decodeIfPresent([String].self, forKey: .photoNames) ?? []
        self.subscriptionTier = try container.decodeIfPresent(SubscriptionTier.self, forKey: .subscriptionTier) ?? .free
        self.githubUsername = try container.decodeIfPresent(String.self, forKey: .githubUsername)
        self.compatibilityScore = try container.decodeIfPresent(Int.self, forKey: .compatibilityScore)
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
        case pending = "PENDING"
        case accepted = "ACCEPTED"
        case declined = "DECLINED"
    }
}

enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "Sistem"
        case .light: return "Açık"
        case .dark: return "Koyu"
        }
    }
    
    var displayNameEN: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case turkish = "tr"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
    
    static func defaultLanguage() -> AppLanguage {
        let identifier = Locale.current.language.languageCode?.identifier ?? "en"
        if identifier.hasPrefix("tr") {
            return .turkish
        }
        return .english
    }
}

struct Localization {
    static func string(_ key: String, lang: AppLanguage) -> String {
        let translations: [AppLanguage: [String: String]] = [
            .turkish: [
                "discover": "Keşfet",
                "messages": "Mesajlar",
                "profile": "Profilim",
                "login_desc": "Profesyonel eşleşmeye başlamak için giriş yapın.",
                "login_github": "GitHub ile Giriş Yap",
                "login_apple": "Apple ile Giriş Yap",
                "login_guest": "Misafir Olarak Keşfet",
                "login_terms": "Giriş yaparak, Kullanım Şartları ve Gizlilik Politikası'nı kabul etmiş olursunuz.",
                "empty_deck": "Buralarda Kimse Kalmadı!",
                "empty_deck_desc": "Teknoloji yığınını düzenleyerek veya Keşfet'i yenileyerek yeni profiller bulabilirsin.",
                "refresh_deck": "Desteyi Yenile",
                "pass": "PAS",
                "like": "BEĞEN",
                "compatibility": "Uyum",
                "target": "Hedef",
                "match_title": "BAĞLANTI KURULDU!",
                "match_desc": "İki taraf da birbiriyle eşleşti.",
                "match_send_message": "Hemen Mesaj Gönder",
                "match_continue": "Kaydırmaya Devam Et",
                "connections": "Bağlantılarım",
                "new_matches": "Yeni Eşleşmeler",
                "no_messages": "Henüz Mesaj Yok",
                "no_messages_desc": "Keşfet ekranından beğendiğin geliştiricilerle eşleşerek sohbeti başlatabilirsin.",
                "coffee_chat_invite": "Kahve Daveti",
                "coffee_chat_title": "Kahve Sohbeti Daveti",
                "coffee_chat_plan": "Kahve Sohbeti Planla",
                "date_and_time": "Tarih ve Saat",
                "cancel": "İptal",
                "send_invite": "Davet Gönder",
                "profile_info": "Profil Bilgileri",
                "display_name": "Görünen İsim",
                "role": "Rol / Ünvan",
                "sector": "Sektör",
                "experience": "Deneyim",
                "years": "Yıl",
                "what_looking_for": "Ne Arıyorsun?",
                "bio": "Hakkımda (Maks 300 Karakter)",
                "tech_stack": "Teknoloji Yığınım",
                "add_tech": "Teknoloji ekle (Örn: Golang)",
                "save_profile": "Profili Kaydet",
                "success": "Başarılı",
                "profile_saved_desc": "Profil bilgileriniz başarıyla güncellendi.",
                "theme": "Arayüz Teması",
                "language": "Dil Seçeneği",
                "cancel_sub": "Aboneliği İptal Et (Demo)",
                "pro_desc_active": "Premium Üyeliğiniz Aktif!",
                "pro_desc_inactive": "Sınırsız eşleşme ve pro filtreler",
                "active": "Aktif",
                "upgrade": "Yükselt",
                "chat_start_helper": "Şimdi eşleştiniz! Merhaba deyin.",
                "save": "Kaydet",
                "stepper_label": "Yıl",
                "success_title": "Başarılı",
                "onboarding_title_1": "Geliştirici Ağı",
                "onboarding_desc_1": "Yazılımcılar ve tasarımcılar için yeni nesil bağlantı platformu.",
                "onboarding_title_2": "Akıllı Eşleşme",
                "onboarding_desc_2": "Teknoloji yığınınıza ve hedeflerinize göre en uyumlu profesyonelleri bulun.",
                "onboarding_title_3": "Kahve Sohbetleri",
                "onboarding_desc_3": "Kahve daveti planlayarak tecrübelerinizi paylaşın veya projelere başlayın.",
                "skip": "Atla",
                "get_started": "Başla",
                "next": "İleri"
            ],
            .english: [
                "discover": "Discover",
                "messages": "Messages",
                "profile": "Profile",
                "login_desc": "Sign in to start matching professionally.",
                "login_github": "Sign In with GitHub",
                "login_apple": "Sign In with Apple",
                "login_guest": "Explore as Guest",
                "login_terms": "By signing in, you accept the Terms of Use and Privacy Policy.",
                "empty_deck": "No One Left Around Here!",
                "empty_deck_desc": "You can find new profiles by editing your tech stack or refreshing the deck.",
                "refresh_deck": "Refresh Deck",
                "pass": "PASS",
                "like": "LIKE",
                "compatibility": "Match",
                "target": "Goal",
                "match_title": "CONNECTION ESTABLISHED!",
                "match_desc": "Both parties matched with each other.",
                "match_send_message": "Send Message Now",
                "match_continue": "Continue Swiping",
                "connections": "Connections",
                "new_matches": "New Matches",
                "no_messages": "No Messages Yet",
                "no_messages_desc": "You can match with developers you like from the Discover screen and start a conversation.",
                "coffee_chat_invite": "Coffee Invite",
                "coffee_chat_title": "Coffee Chat Invitation",
                "coffee_chat_plan": "Plan Coffee Chat",
                "date_and_time": "Date and Time",
                "cancel": "Cancel",
                "send_invite": "Send Invitation",
                "profile_info": "Profile Information",
                "display_name": "Display Name",
                "role": "Role / Title",
                "sector": "Sector",
                "experience": "Experience",
                "years": "Years",
                "what_looking_for": "What are you looking for?",
                "bio": "Bio (Max 300 Characters)",
                "tech_stack": "My Tech Stack",
                "add_tech": "Add technology (e.g. Golang)",
                "save_profile": "Save Profile",
                "success": "Success",
                "profile_saved_desc": "Your profile information was updated successfully.",
                "theme": "Theme",
                "language": "Language",
                "cancel_sub": "Cancel Subscription (Demo)",
                "pro_desc_active": "Your Premium Membership is Active!",
                "pro_desc_inactive": "Unlimited swipes and pro filters",
                "active": "Active",
                "upgrade": "Upgrade",
                "chat_placeholder": "Type your message...",
                "chat_start_helper": "You matched! Say hello.",
                "save": "Save",
                "stepper_label": "Years",
                "success_title": "Success",
                "onboarding_title_1": "Developer Network",
                "onboarding_desc_1": "Next-gen networking platform for developers and designers.",
                "onboarding_title_2": "Smart Matching",
                "onboarding_desc_2": "Find the most compatible professionals based on tech stack and goals.",
                "onboarding_title_3": "Coffee Chats",
                "onboarding_desc_3": "Plan coffee chats to share experiences or launch side projects.",
                "skip": "Skip",
                "get_started": "Get Started",
                "next": "Next"
            ]
        ]
        return translations[lang]?[key] ?? key
    }
}

