import Foundation
import SwiftUI

enum Sector: String, Codable, CaseIterable {
    case startup = "STARTUP"
    case corporate = "CORPORATE"
    case freelance = "FREELANCE"
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .startup: return "Startup"
        case .corporate:
            switch lang {
            case .turkish: return "Kurumsal"
            case .english: return "Corporate"
            case .russian: return "Корпоративный"
            case .japanese: return "企業"
            case .german: return "Unternehmen"
            case .spanish: return "Corporativo"
            }
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
        case .mentor:
            switch lang {
            case .turkish: return "Mentör"
            case .english: return "Mentor"
            case .russian: return "Ментор"
            case .japanese: return "メンター"
            case .german: return "Mentor"
            case .spanish: return "Mentor"
            }
        case .mentee:
            switch lang {
            case .turkish: return "Mentee"
            case .english: return "Mentee"
            case .russian: return "Менти"
            case .japanese: return "メンティ"
            case .german: return "Mentee"
            case .spanish: return "Aprendiz"
            }
        case .collaboration:
            switch lang {
            case .turkish: return "Proje Ortaklığı"
            case .english: return "Collaboration"
            case .russian: return "Сотрудничество"
            case .japanese: return "コラボレーション"
            case .german: return "Zusammenarbeit"
            case .spanish: return "Colaboración"
            }
        case .coffeeChat:
            switch lang {
            case .turkish: return "Kahve Sohbeti"
            case .english: return "Coffee Chat"
            case .russian: return "Кофе-чат"
            case .japanese: return "コーヒーチャット"
            case .german: return "Kaffee-Chat"
            case .spanish: return "Charla de café"
            }
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

enum Gender: String, Codable, CaseIterable {
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .male:
            switch lang {
            case .turkish: return "Erkek"
            case .english: return "Male"
            case .russian: return "Мужской"
            case .japanese: return "男性"
            case .german: return "Männlich"
            case .spanish: return "Masculino"
            }
        case .female:
            switch lang {
            case .turkish: return "Kadın"
            case .english: return "Female"
            case .russian: return "Женский"
            case .japanese: return "女性"
            case .german: return "Weiblich"
            case .spanish: return "Femenino"
            }
        case .other:
            switch lang {
            case .turkish: return "Diğer"
            case .english: return "Other"
            case .russian: return "Другой"
            case .japanese: return "その他"
            case .german: return "Andere"
            case .spanish: return "Otro"
            }
        }
    }
}

enum PreferredGender: String, Codable, CaseIterable {
    case male = "MALE"
    case female = "FEMALE"
    case everyone = "EVERYONE"
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .male:
            switch lang {
            case .turkish: return "Erkekler"
            case .english: return "Men"
            case .russian: return "Мужчины"
            case .japanese: return "男性"
            case .german: return "Männer"
            case .spanish: return "Hombres"
            }
        case .female:
            switch lang {
            case .turkish: return "Kadınlar"
            case .english: return "Women"
            case .russian: return "Женщины"
            case .japanese: return "女性"
            case .german: return "Frauen"
            case .spanish: return "Mujeres"
            }
        case .everyone:
            switch lang {
            case .turkish: return "Herkes"
            case .english: return "Everyone"
            case .russian: return "Все"
            case .japanese: return "全員"
            case .german: return "Alle"
            case .spanish: return "Todos"
            }
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
    var photoNames: [String]
    var subscriptionTier: SubscriptionTier = .free
    var githubUsername: String?
    var compatibilityScore: Int?
    var gender: Gender = .male
    var preferredGender: PreferredGender = .everyone
    
    enum CodingKeys: String, CodingKey {
        case id, displayName, email, role, experienceYears, sector, bio, lookingFor, city, isRemote, techStack, photoNames, subscriptionTier, githubUsername, compatibilityScore, gender, preferredGender
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
        compatibilityScore: Int? = nil,
        gender: Gender = .male,
        preferredGender: PreferredGender = .everyone
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
        self.gender = gender
        self.preferredGender = preferredGender
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
        self.gender = try container.decodeIfPresent(Gender.self, forKey: .gender) ?? .male
        self.preferredGender = try container.decodeIfPresent(PreferredGender.self, forKey: .preferredGender) ?? .everyone
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
    
    func displayName(lang: AppLanguage) -> String {
        switch self {
        case .system:
            switch lang {
            case .turkish: return "Sistem"
            case .english: return "System"
            case .russian: return "Системная"
            case .japanese: return "システム"
            case .german: return "System"
            case .spanish: return "Sistema"
            }
        case .light:
            switch lang {
            case .turkish: return "Açık"
            case .english: return "Light"
            case .russian: return "Светлая"
            case .japanese: return "ライト"
            case .german: return "Hell"
            case .spanish: return "Claro"
            }
        case .dark:
            switch lang {
            case .turkish: return "Koyu"
            case .english: return "Dark"
            case .russian: return "Темная"
            case .japanese: return "ダーク"
            case .german: return "Dunkel"
            case .spanish: return "Oscuro"
            }
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
    case russian = "ru"
    case japanese = "ja"
    case german = "de"
    case spanish = "es"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        case .russian: return "Русский"
        case .japanese: return "日本語"
        case .german: return "Deutsch"
        case .spanish: return "Español"
        }
    }
    
    static func defaultLanguage() -> AppLanguage {
        let identifier = Locale.current.language.languageCode?.identifier ?? "en"
        if identifier.hasPrefix("tr") {
            return .turkish
        } else if identifier.hasPrefix("ru") {
            return .russian
        } else if identifier.hasPrefix("ja") {
            return .japanese
        } else if identifier.hasPrefix("de") {
            return .german
        } else if identifier.hasPrefix("es") {
            return .spanish
        }
        return .english
    }
}

struct Localization {
    static func localizedError(_ error: Error, lang: AppLanguage) -> String {
        let nsError = error as NSError
        
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case -1001:
                return lang == .turkish 
                    ? "Sunucu bağlantısı zaman aşımına uğradı. Sunucu uyanıyor olabilir (soğuk başlatma 50 saniye sürebilir), lütfen birazdan tekrar deneyin." 
                    : "The request timed out. The server might be waking up (cold start can take up to 50s), please try again shortly."
            case -1004:
                return lang == .turkish 
                    ? "Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol edin." 
                    : "Could not connect to the server. Please check your internet connection."
            case -1009:
                return lang == .turkish 
                    ? "İnternet bağlantınız bulunmuyor. Lütfen bağlantınızı kontrol edin." 
                    : "No internet connection available. Please check your connection."
            default:
                break
            }
        }
        
        let message = nsError.localizedDescription
        
        if lang == .turkish {
            if message.contains("timed out") {
                return "Sunucu bağlantısı zaman aşımına uğradı. Lütfen tekrar deneyin."
            }
            if message.contains("400") || message.contains("Bad Request") {
                return "Geçersiz istek. Lütfen alanları kontrol edin."
            }
            if message.contains("403") || message.contains("Forbidden") {
                return "Erişim reddedildi. Lütfen bilgilerinizi kontrol edin."
            }
            if message.contains("409") || message.contains("Conflict") {
                return "Bu e-posta veya GitHub kullanıcı adı zaten kayıtlı."
            }
            if message.contains("GitHub kullanıcı adı zorunludur") {
                return "GitHub kullanıcı adı zorunludur."
            }
            if message.contains("E-posta veya şifre hatalı") {
                return "E-posta veya şifre hatalı."
            }
        }
        
        return message
    }

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
                "chat_placeholder": "Mesajınızı yazın...",
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
                "next": "İleri",
                // Newly added keys for full view localizations
                "signup_title": "Kayıt Ol",
                "likes": "Beğeniler",
                "likes_desc": "Seni Beğenenler",
                "likes_blur_message": "Seni beğenen diğer yazılımcıları görmek ve anında eşleşmek için PRO'ya yüksel!",
                "likes_empty": "Henüz Beğeni Yok",
                "likes_empty_desc": "Profilini doldurarak ve aktif olarak kaydırarak diğer geliştiricilerin ilgisini çekebilirsin.",
                "complete_register": "Kaydı Tamamla",
                "continue_btn": "İlerle",
                "example_name": "Örn: Ahmet",
                "email_address": "E-posta Adresi",
                "password": "Şifre",
                "github_username_verify": "GitHub Kullanıcı Adı (IT Doğrulaması)",
                "username_placeholder": "Kullanıcı adınız",
                "github_required_warning": "⚠️ Platformumuz yalnızca bilişim ve teknoloji çalışanlarına açık olduğu için geçerli bir GitHub hesabı gerekmektedir.",
                "example_role": "Örn: iOS Geliştirici",
                "city": "Şehir",
                "work_remotely": "Uzaktan Çalışıyorum (Remote)",
                "add_tech_placeholder": "Teknoloji ekle (Golang vb)",
                "matching_goal": "Eşleşme Hedefiniz",
                "fill_all_info_error": "Lütfen tüm bilgileri doldurun.",
                "fill_role_city_error": "Lütfen rol ve şehir alanlarını doldurun.",
                "add_at_least_one_tech_error": "Lütfen en az bir teknoloji ekleyin.",
                "login_title": "Giriş Yap",
                "dont_have_account": "Hesabınız yok mu?",
                "login_with_email": "E-posta ile Giriş Yap",
                "or_text": "veya",
                "fill_all_fields_error": "Lütfen tüm alanları doldurun.",
                "error_title": "Hata",
                "paywall_unlock_desc": "Geliştirici dünyasındaki ayrıcalıklarınızı kilitleyin.",
                "unlimited_likes": "Sınırsız Beğeni",
                "unlimited_likes_desc": "Günde 10 beğeni sınırını kaldırın, dilediğinizce kaydırın.",
                "advanced_filters": "Gelişmiş Filtreler",
                "advanced_filters_desc": "Teknoloji yığını, şehir ve deneyime göre filtreleyin.",
                "rewind_title": "Geri Al (Rewind)",
                "rewind_desc": "Sola kaydırdığınız son profilleri anında geri getirin.",
                "profile_boost": "Profil Öne Çıkarma",
                "profile_boost_desc": "Keşfet listelerinde üstte görünün, 5 kat daha hızlı eşleşin.",
                "select_a_plan": "Bir Plan Seçin",
                "monthly_plan": "Aylık Plan",
                "cancel_anytime": "Dilediğin zaman iptal et",
                "yearly_plan": "Yıllık Plan",
                "yearly_savings_format": "%@ / yıl (%%40 Tasarruf)",
                "popular_badge": "POPÜLER",
                "upgrade_to_pro": "PRO ÜYELİĞE GEÇ",
                "restore_purchases": "Satın Almaları Geri Yükle",
                "terms_of_service": "Kullanım Şartları",
                "congratulations": "TEBRİKLER!",
                "pro_privileges_unlocked": "DevMatch PRO Ayrıcalıkları Tanımlandı!",
                "start_using": "Kullanmaya Başla",
                "processing": "İşleniyor...",
                "no_subscriptions_found": "Geri yüklenecek abonelik bulunamadı.",
                "delete_account_title": "Hesabımı Sil",
                "cancel_action": "Vazgeç",
                "delete_confirm_action": "Evet, Sil",
                "delete_account_message": "Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm eşleşmeleriniz ile mesajlarınız silinecektir.",
                "manage_subscription": "Aboneliği Yönet (Customer Center)",
                "app_settings": "Uygulama Ayarları",
                "info_account_section": "Bilgi & Hesap",
                "about_app": "Uygulama Hakkında",
                "terms_of_use": "Kullanım Koşulları",
                "privacy_policy": "Gizlilik Politikası",
                "contact_us": "Bize Ulaşın",
                "log_out": "Çıkış Yap",
                "close_action": "Kapat",
                "about_app_desc": "DevMatch, yazılımcı ve teknoloji profesyonellerinin ortak projeler geliştirmek, kahve sohbetleri yapmak veya mentörlük ilişkileri kurmak için birbirleriyle eşleşmesini sağlayan premium bir networking platformudur.",
                "terms_use_1_title": "1. Kabul Edilebilir Kullanım",
                "terms_use_1_desc": "DevMatch yalnızca bilişim, yazılım ve teknoloji çalışanları için tasarlanmıştır. Platformumuzda sahte profil oluşturmak veya diğer kullanıcıları rahatsız etmek yasaktır.",
                "terms_use_2_title": "2. Hesap Sorumluluğu",
                "terms_use_2_desc": "Kullanıcılar hesaplarının güvenliğinden und yaptıkları paylaşımlardan kendileri sorumludur. GitHub hesabınız doğrulanmış olmalıdır.",
                "terms_use_3_title": "3. Abonelik Koşulları",
                "terms_use_3_desc": "DevMatch PRO abonelikleri Apple App Store veya entegre faturalandırma sistemi aracılığıyla yönetilir. Satın alımlar iptal edilene kadar otomatik yenilenir.",
                "privacy_1_title": "1. Toplanan Veriler",
                "privacy_1_desc": "Uygulamaya kayıt olurken verdiğiniz e-posta, ad soyad, rol, deneyim yılı, şehir ve yüklediğiniz profil resimleri güvenli bir şekilde PostgreSQL veritabanımızda saklanır.",
                "privacy_2_title": "2. GitHub Entegrasyonu",
                "privacy_2_desc": "Verifikasyon amacıyla GitHub kullanıcı adınız sorgulanır. Şifreniz veya özel hesap bilgileriniz asla talep edilmez ve saklanmaz.",
                "privacy_3_title": "3. Veri Güvenliği",
                "privacy_3_desc": "Şifreniz BCrypt algoritması ile hash'lenerek saklanır. Verileriniz üçüncü şahıslarla asla paylaşılmaz.",
                "contact_desc": "Sorularınız, iş birliği talepleriniz veya destek ihtiyaçlarınız için bize e-posta yoluyla ulaşabilirsiniz.",
                "gender": "Cinsiyet",
                "preferred_gender": "Karşılaşmak İstediğim Cinsiyet",
                "like_limit_exceeded_title": "Günlük Beğeni Sınırına Ulaşıldı",
                "like_limit_exceeded_desc": "Günde en fazla 10 beğeni atabilirsiniz. Sınırsız beğeni için DevMatch PRO'ya yükseltin!"
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
                "next": "Next",
                "signup_title": "Sign Up",
                "likes": "Likes",
                "likes_desc": "Who Liked You",
                "likes_blur_message": "Upgrade to PRO to see other developers who liked you and match instantly!",
                "likes_empty": "No Likes Yet",
                "likes_empty_desc": "Keep your profile updated and swipe actively to get noticed by other developers.",
                "complete_register": "Complete Register",
                "continue_btn": "Continue",
                "example_name": "e.g. Ahmet",
                "email_address": "Email Address",
                "password": "Password",
                "github_username_verify": "GitHub Username (IT Verification)",
                "username_placeholder": "Your username",
                "github_required_warning": "⚠️ Since our platform is only open to tech and IT professionals, a valid GitHub account is required.",
                "example_role": "e.g. iOS Developer",
                "city": "City",
                "work_remotely": "I work Remotely",
                "add_tech_placeholder": "Add technology (e.g. Swift)",
                "matching_goal": "Matching Goal",
                "fill_all_info_error": "Please fill in all information.",
                "fill_role_city_error": "Please fill in role and city fields.",
                "add_at_least_one_tech_error": "Please add at least one technology.",
                "login_title": "Log In",
                "dont_have_account": "Don't have an account?",
                "login_with_email": "Login with Email",
                "or_text": "or",
                "fill_all_fields_error": "Please fill in all fields.",
                "error_title": "Error",
                "paywall_unlock_desc": "Unlock your privileges in the tech community.",
                "unlimited_likes": "Unlimited Likes",
                "unlimited_likes_desc": "Remove the 10 likes limit, swipe as much as you want.",
                "advanced_filters": "Advanced Filters",
                "advanced_filters_desc": "Filter by technology stack, city, and years of experience.",
                "rewind_title": "Rewind",
                "rewind_desc": "Instantly bring back profiles you accidentally passed.",
                "profile_boost": "Profile Boost",
                "profile_boost_desc": "Get featured at the top of discover decks for 5x faster matches.",
                "select_a_plan": "Select a Plan",
                "monthly_plan": "Monthly Plan",
                "cancel_anytime": "Cancel anytime",
                "yearly_plan": "Yearly Plan",
                "yearly_savings_format": "%@ / yr (Save 40%)",
                "popular_badge": "POPULAR",
                "upgrade_to_pro": "UPGRADE TO PRO",
                "restore_purchases": "Restore Purchases",
                "terms_of_service": "Terms of Service",
                "congratulations": "CONGRATULATIONS!",
                "pro_privileges_unlocked": "DevMatch PRO Privileges Unlocked!",
                "start_using": "Start Using",
                "processing": "Processing...",
                "no_subscriptions_found": "No subscriptions found to restore.",
                "delete_account_title": "Delete Account",
                "cancel_action": "Cancel",
                "delete_confirm_action": "Yes, Delete",
                "delete_account_message": "Are you sure you want to delete your account? This action is permanent and will delete all matches and chats.",
                "manage_subscription": "Manage Subscription",
                "app_settings": "App Settings",
                "info_account_section": "Info & Account",
                "about_app": "About App",
                "terms_of_use": "Terms of Use",
                "privacy_policy": "Privacy Policy",
                "contact_us": "Contact Us",
                "log_out": "Log Out",
                "close_action": "Close",
                "about_app_desc": "DevMatch is a premium networking platform that allows developers and tech professionals to match for side projects, coffee chats, or mentor-mentee collaborations.",
                "terms_use_1_title": "1. Acceptable Use",
                "terms_use_1_desc": "DevMatch is exclusively designed for IT, software, and tech professionals. Creating fake profiles or harassing other users is strictly prohibited.",
                "terms_use_2_title": "2. Account Responsibility",
                "terms_use_2_desc": "Users are responsible for their account security and activities. A verified GitHub account is required.",
                "terms_use_3_title": "3. Subscription Terms",
                "terms_use_3_desc": "DevMatch PRO subscriptions are billed through Apple App Store or integrated processing. Auto-renews until cancelled.",
                "privacy_1_title": "1. Collected Data",
                "privacy_1_desc": "Your email, display name, role, experience, city, bio, and profile photos are securely stored in our PostgreSQL database.",
                "privacy_2_title": "2. GitHub Integration",
                "privacy_2_desc": "Your GitHub username is queried for verification. We never request or store your GitHub credentials.",
                "privacy_3_title": "3. Data Security",
                "privacy_3_desc": "Passwords are cryptographically hashed using BCrypt. Your personal data is never shared with third parties.",
                "contact_desc": "For any support requests, questions, or collaboration offers, feel free to reach out to us.",
                "gender": "Gender",
                "preferred_gender": "Preferred Gender",
                "like_limit_exceeded_title": "Daily Like Limit Reached",
                "like_limit_exceeded_desc": "You can like up to 10 profiles per day. Upgrade to DevMatch PRO for unlimited likes!"
            ],
            .spanish: [
                "discover": "Descubrir",
                "messages": "Mensajes",
                "profile": "Mi Perfil",
                "login_desc": "Inicia sesión para empezar a conectar profesionalmente.",
                "login_github": "Iniciar sesión con GitHub",
                "login_apple": "Iniciar sesión con Apple",
                "login_guest": "Explorar como Invitado",
                "login_terms": "Al iniciar sesión, aceptas las Condiciones de uso y la Política de privacidad.",
                "empty_deck": "¡No queda nadie por aquí!",
                "empty_deck_desc": "Puedes encontrar nuevos perfiles editando tu stack tecnológico o actualizando el mazo.",
                "refresh_deck": "Actualizar Mazo",
                "pass": "PASAR",
                "like": "ME GUSTA",
                "compatibility": "Compatibilidad",
                "target": "Objetivo",
                "match_title": "¡CONEXIÓN ESTABLECIDA!",
                "match_desc": "Ambas partes han coincidido.",
                "match_send_message": "Enviar mensaje ahora",
                "match_continue": "Seguir deslizando",
                "connections": "Mis Conexiones",
                "new_matches": "Nuevas Coincidencias",
                "no_messages": "Aún no hay mensajes",
                "no_messages_desc": "Puedes emparejarte con desarrolladores que te gusten en Descubrir e iniciar un chat.",
                "coffee_chat_invite": "Invitar a Café",
                "coffee_chat_title": "Invitación a Charla de Café",
                "coffee_chat_plan": "Planificar Charla de Café",
                "date_and_time": "Fecha y hora",
                "cancel": "Cancelar",
                "send_invite": "Enviar invitación",
                "profile_info": "Información del Perfil",
                "display_name": "Nombre de Mostrar",
                "role": "Rol / Cargo",
                "sector": "Sector",
                "experience": "Experiencia",
                "years": "Años",
                "what_looking_for": "¿Qué estás buscando?",
                "bio": "Sobre mí (Máx. 300 caracteres)",
                "tech_stack": "Mi Stack Tecnológico",
                "add_tech": "Añadir tecnología (p. ej. Golang)",
                "save_profile": "Guardar Perfil",
                "success": "Éxito",
                "profile_saved_desc": "Tu información de perfil se ha actualizado correctamente.",
                "theme": "Tema",
                "language": "Idioma",
                "cancel_sub": "Cancelar Suscripción (Demo)",
                "pro_desc_active": "¡Tu membresía Premium está activa!",
                "pro_desc_inactive": "Deslizamientos ilimitados y filtros pro",
                "active": "Activo",
                "upgrade": "Mejorar",
                "chat_placeholder": "Escribe tu mensaje...",
                "chat_start_helper": "¡Habéis coincidido! Di hola.",
                "save": "Guardar",
                "stepper_label": "Años",
                "success_title": "Éxito",
                "onboarding_title_1": "Red de Desarrolladores",
                "onboarding_desc_1": "Plataforma de networking de última generación para desarrolladores y diseñadores.",
                "onboarding_title_2": "Coincidencia Inteligente",
                "onboarding_desc_2": "Encuentra a los profesionales más compatibles según tu stack tecnológico y objetivos.",
                "onboarding_title_3": "Charlas de Café",
                "onboarding_desc_3": "Planifica charlas de café para compartir experiencias o iniciar proyectos paralelos.",
                "skip": "Saltar",
                "get_started": "Comenzar",
                "next": "Siguiente",
                "signup_title": "Registrarse",
                "complete_register": "Completar Registro",
                "continue_btn": "Continuar",
                "example_name": "p. ej. Ahmet",
                "email_address": "Dirección de correo",
                "password": "Contraseña",
                "github_username_verify": "Usuario de GitHub (Verificación de TI)",
                "username_placeholder": "Tu usuario",
                "github_required_warning": "⚠️ Dado que nuestra plataforma solo está abierta a profesionales de la tecnología y TI, se requiere una cuenta de GitHub válida.",
                "example_role": "p. ej. Desarrollador iOS",
                "city": "Ciudad",
                "work_remotely": "Trabajo en remoto",
                "add_tech_placeholder": "Añadir tecnología (p. ej. Swift)",
                "matching_goal": "Objetivo de emparejamiento",
                "fill_all_info_error": "Por favor, complete toda la información.",
                "fill_role_city_error": "Por favor, complete los campos de rol y ciudad.",
                "add_at_least_one_tech_error": "Por favor, añada al menos una tecnología.",
                "login_title": "Iniciar sesión",
                "dont_have_account": "¿No tienes cuenta?",
                "login_with_email": "Iniciar sesión con correo",
                "or_text": "o",
                "fill_all_fields_error": "Por favor, rellene todos los campos.",
                "error_title": "Error",
                "paywall_unlock_desc": "Desbloquea tus privilegios en la comunidad tecnológica.",
                "unlimited_likes": "Likes ilimitados",
                "unlimited_likes_desc": "Elimina el límite de 10 likes, desliza todo lo que quieras.",
                "advanced_filters": "Filtros avanzados",
                "advanced_filters_desc": "Filtra por stack tecnológico, ciudad y años de experiencia.",
                "rewind_title": "Rebobinar",
                "rewind_desc": "Recupera al instante los perfiles descartados por error.",
                "profile_boost": "Boost de perfil",
                "profile_boost_desc": "Destaca en la parte superior para conseguir matches 5 veces más rápido.",
                "select_a_plan": "Selecciona un plan",
                "monthly_plan": "Plan mensual",
                "cancel_anytime": "Cancela en cualquier momento",
                "yearly_plan": "Plan anual",
                "yearly_savings_format": "%@ / año (Ahorra 40%%)",
                "popular_badge": "POPULAR",
                "upgrade_to_pro": "MEJORAR A PRO",
                "restore_purchases": "Restaurar compras",
                "terms_of_service": "Términos de servicio",
                "congratulations": "¡FELICIDADES!",
                "pro_privileges_unlocked": "¡Privilegios de DevMatch PRO desbloqueados!",
                "start_using": "Empezar a usar",
                "processing": "Procesando...",
                "no_subscriptions_found": "No se encontraron suscripciones para restaurar.",
                "delete_account_title": "Eliminar cuenta",
                "cancel_action": "Cancelar",
                "delete_confirm_action": "Sí, eliminar",
                "delete_account_message": "¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es permanente y eliminará todos los matches y chats.",
                "manage_subscription": "Gestionar suscripción",
                "app_settings": "Ajustes de la aplicación",
                "info_account_section": "Información y cuenta",
                "about_app": "Acerca de la app",
                "terms_of_use": "Condiciones de uso",
                "privacy_policy": "Política de privacidad",
                "contact_us": "Contáctanos",
                "log_out": "Cerrar sesión",
                "close_action": "Cerrar",
                "about_app_desc": "DevMatch es una plataforma de networking premium que permite a los desarrolladores y profesionales de la tecnología coincidir para proyectos secundarios, charlas de café o mentorías.",
                "terms_use_1_title": "1. Uso Aceptable",
                "terms_use_1_desc": "DevMatch está diseñado exclusivamente para profesionales de TI, software y tecnología. Está prohibido crear perfiles falsos o acosar a otros usuarios.",
                "terms_use_2_title": "2. Responsabilidad de la Cuenta",
                "terms_use_2_desc": "Los usuarios son responsables de la seguridad de su cuenta y de sus actividades. Se requiere una cuenta de GitHub verificada.",
                "terms_use_3_title": "3. Condiciones de Suscripción",
                "terms_use_3_desc": "Las suscripciones de DevMatch PRO se facturan a través de Apple App Store o procesamiento integrado. Se renuevan automáticamente hasta su cancelación.",
                "privacy_1_title": "1. Datos Recopilados",
                "privacy_1_desc": "Tu correo, nombre de mostrar, rol, experiencia, ciudad, biografía y fotos de perfil se almacenan de forma segura en nuestra base de datos PostgreSQL.",
                "privacy_2_title": "2. Integración con GitHub",
                "privacy_2_desc": "Tu nombre de usuario de GitHub se consulta para verificación. Nunca solicitamos ni almacenamos tus credenciales de GitHub.",
                "privacy_3_title": "3. Seguridad de Datos",
                "privacy_3_desc": "Las contraseñas se cifran mediante algoritmos BCrypt. Tus datos personales nunca se comparten con terceros.",
                "contact_desc": "Para cualquier consulta de soporte, preguntas u ofertas de colaboración, no dudes en ponerte en contacto con nosotros.",
                "gender": "Género",
                "preferred_gender": "Género preferido",
                "like_limit_exceeded_title": "Límite de likes diarios alcanzado",
                "like_limit_exceeded_desc": "Puedes dar me gusta hasta a 10 perfiles por día. ¡Actualiza a DevMatch PRO para likes ilimitados!"
            ],
            .german: [
                "discover": "Entdecken",
                "messages": "Nachrichten",
                "profile": "Mein Profil",
                "login_desc": "Melden Sie sich an, um Kontakte in der Tech-Branche zu knüpfen.",
                "login_github": "Mit GitHub anmelden",
                "login_apple": "Mit Apple anmelden",
                "login_guest": "Als Gast erkunden",
                "login_terms": "Mit der Anmeldung akzeptieren Sie die Nutzungsbedingungen und die Datenschutzerklärung.",
                "empty_deck": "Niemand mehr hier!",
                "empty_deck_desc": "Fügen Sie neue Technologien hinzu oder aktualisieren Sie den Stapel, um neue Profile zu finden.",
                "refresh_deck": "Stapel aktualisieren",
                "pass": "PASSE",
                "like": "GEFÄLLT MIR",
                "compatibility": "Kompatibilität",
                "target": "Ziel",
                "match_title": "VERBINDUNG HERGESTELLT!",
                "match_desc": "Sie haben ein gegenseitiges Match.",
                "match_send_message": "Jetzt Nachricht senden",
                "match_continue": "Weiter swipen",
                "connections": "Verbindungen",
                "new_matches": "Neue Matches",
                "no_messages": "Noch keine Nachrichten",
                "no_messages_desc": "Sie können einen Chat starten, nachdem Sie ein Match auf dem Entdecken-Bildschirm haben.",
                "coffee_chat_invite": "Kaffee-Einladung",
                "coffee_chat_title": "Einladung zum Kaffee-Chat",
                "coffee_chat_plan": "Kaffee-Chat planen",
                "date_and_time": "Datum & Uhrzeit",
                "cancel": "Abbrechen",
                "send_invite": "Einladung senden",
                "profile_info": "Profil-Informationen",
                "display_name": "Anzeigename",
                "role": "Rolle / Titel",
                "sector": "Bereich",
                "experience": "Erfahrung",
                "years": "Jahre",
                "what_looking_for": "Wonach suchen Sie?",
                "bio": "Über mich (Max. 300 Zeichen)",
                "tech_stack": "Mein Tech-Stack",
                "add_tech": "Technologie hinzufügen (z.B. Golang)",
                "save_profile": "Profil speichern",
                "success": "Erfolgreich",
                "profile_saved_desc": "Ihr Profil wurde erfolgreich aktualisiert.",
                "theme": "Design",
                "language": "Sprache",
                "cancel_sub": "Abonnement kündigen (Demo)",
                "pro_desc_active": "Premium-Mitgliedschaft ist aktiv!",
                "pro_desc_inactive": "Unbegrenzte Matches und Pro-Filter",
                "active": "Aktiv",
                "upgrade": "Upgrade",
                "chat_placeholder": "Nachricht schreiben...",
                "chat_start_helper": "Match hergestellt! Sagen Sie Hallo.",
                "save": "Speichern",
                "stepper_label": "Jahre",
                "success_title": "Erfolg",
                "onboarding_title_1": "Entwickler-Netzwerk",
                "onboarding_desc_1": "Die nächste Generation von Netzwerken für Entwickler und Designer.",
                "onboarding_title_2": "Intelligentes Matching",
                "onboarding_desc_2": "Finden Sie die passendsten Fachkräfte basierend auf Tech-Stack und Zielen.",
                "onboarding_title_3": "Kaffee-Chats",
                "onboarding_desc_3": "Planen Sie Kaffee-Chats, um Erfahrungen auszutauschen oder Projekte zu starten.",
                "skip": "Überspringen",
                "get_started": "Loslegen",
                "next": "Weiter",
                "signup_title": "Registrieren",
                "complete_register": "Registrierung abschließen",
                "continue_btn": "Weiter",
                "example_name": "z.B. Ahmet",
                "email_address": "E-Mail-Adresse",
                "password": "Passwort",
                "github_username_verify": "GitHub-Benutzername (IT-Verifizierung)",
                "username_placeholder": "Ihr Benutzername",
                "github_required_warning": "⚠️ Da unsere Plattform nur für IT- und Technologie-Experten zugänglich ist, ist ein gültiges GitHub-Konto erforderlich.",
                "example_role": "z.B. iOS-Entwickler",
                "city": "Stadt",
                "work_remotely": "Ich arbeite remote",
                "add_tech_placeholder": "Technologie hinzufügen (z.B. Swift)",
                "matching_goal": "Match-Ziel",
                "fill_all_info_error": "Bitte füllen Sie alle Informationen aus.",
                "fill_role_city_error": "Bitte füllen Sie die Felder für Rolle und Stadt aus.",
                "add_at_least_one_tech_error": "Bitte fügen Sie mindestens eine Technologie hinzu.",
                "login_title": "Einloggen",
                "dont_have_account": "Haben Sie kein Konto?",
                "login_with_email": "Mit E-Mail einloggen",
                "or_text": "oder",
                "fill_all_fields_error": "Bitte füllen Sie alle Felder aus.",
                "error_title": "Fehler",
                "paywall_unlock_desc": "Schalten Sie Ihre Privilegien in der Tech-Community frei.",
                "unlimited_likes": "Unbegrenzte Likes",
                "unlimited_likes_desc": "Heben Sie das Limit von 10 Likes auf, swipen Sie so viel Sie wollen.",
                "advanced_filters": "Erweiterte Filter",
                "advanced_filters_desc": "Filtern Sie nach Technologie-Stack, Stadt und Berufserfahrung.",
                "rewind_title": "Zurückspulen",
                "rewind_desc": "Bringen Sie versehentlich übersprungene Profile sofort zurück.",
                "profile_boost": "Profil-Boost",
                "profile_boost_desc": "Werden Sie ganz oben im Entdeckungsstapel angezeigt, um 5x schneller zu matchen.",
                "select_a_plan": "Wählen Sie einen Tarif",
                "monthly_plan": "Monatlicher Tarif",
                "cancel_anytime": "Jederzeit kündbar",
                "yearly_plan": "Jährlicher Tarif",
                "yearly_savings_format": "%@ / Jahr (40%% Ersparnis)",
                "popular_badge": "BELIEBT",
                "upgrade_to_pro": "AUF PRO UPGRADEN",
                "restore_purchases": "Käufe wiederherstellen",
                "terms_of_service": "Nutzungsbedingungen",
                "congratulations": "HERZLICHEN GLÜCKWUNSCH!",
                "pro_privileges_unlocked": "DevMatch PRO Privilegien freigeschaltet!",
                "start_using": "Jetzt nutzen",
                "processing": "Verarbeitung...",
                "no_subscriptions_found": "Keine Abonnements zum Wiederherstellen gefunden.",
                "delete_account_title": "Konto löschen",
                "cancel_action": "Abbrechen",
                "delete_confirm_action": "Ja, löschen",
                "delete_account_message": "Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Dieser Vorgang ist dauerhaft und löscht alle Matches und Chats.",
                "manage_subscription": "Abonnement verwalten",
                "app_settings": "App-Einstellungen",
                "info_account_section": "Info & Konto",
                "about_app": "Über die App",
                "terms_of_use": "Nutzungsbedingungen",
                "privacy_policy": "Datenschutzrichtlinie",
                "contact_us": "Kontakt",
                "log_out": "Ausloggen",
                "close_action": "Schließen",
                "about_app_desc": "DevMatch ist eine Premium-Networking-Plattform für Entwickler und Tech-Experten, um Matches für Nebenprojekte, Kaffee-Chats oder Mentoring zu finden.",
                "terms_use_1_title": "1. Zulässige Nutzung",
                "terms_use_1_desc": "DevMatch ist ausschließlich für IT-, Software- und Technologie-Experten gedacht. Die Erstellung falscher Profile oder Belästigung ist streng untersagt.",
                "terms_use_2_title": "2. Verantwortung für das Konto",
                "terms_use_2_desc": "Nutzer sind für die Sicherheit ihres Kontos verantwortlich. Ein verifiziertes GitHub-Konto ist erforderlich.",
                "terms_use_3_title": "3. Abonnementbedingungen",
                "terms_use_3_desc": "DevMatch PRO-Abonnements werden über den Apple App Store abgerechnet und verlängern sich automatisch bis zur Kündigung.",
                "privacy_1_title": "1. Erhobene Daten",
                "privacy_1_desc": "Ihre E-Mail-Adresse, Ihr Anzeigename, Ihre Rolle, Ihre Erfahrung, Ihre Stadt und Ihre Profilfotos werden sicher in unserer PostgreSQL-Datenbank gespeichert.",
                "privacy_2_title": "2. GitHub-Integration",
                "privacy_2_desc": "Ihr GitHub-Benutzername wird zur Verifizierung abgefragt. Wir fragen niemals nach Ihren GitHub-Zugangsdaten.",
                "privacy_3_title": "3. Datensicherheit",
                "privacy_3_desc": "Passwörter werden mit dem BCrypt-Algorithmus kryptografisch gehasht. Ihre persönlichen Daten werden niemals an Dritte weitergegeben.",
                "contact_desc": "Für Supportanfragen, Fragen oder Kooperationsangebote können Sie uns gerne kontaktieren.",
                "gender": "Geschlecht",
                "preferred_gender": "Bevorzugtes Geschlecht",
                "like_limit_exceeded_title": "Tägliches Like-Limit erreicht",
                "like_limit_exceeded_desc": "Sie können bis zu 10 Profile pro Tag liken. Aktualisieren Sie auf DevMatch PRO für unbegrenzte Likes!"
            ],
            .japanese: [
                "discover": "発見",
                "messages": "メッセージ",
                "profile": "マイプロフィール",
                "login_desc": "サインインして、プロフェッショナルなマッチングを始めましょう。",
                "login_github": "GitHubでサインイン",
                "login_apple": "Appleでサインイン",
                "login_guest": "ゲストとして探索",
                "login_terms": "サインインすることで、利用規約とプライバシーポリシーに同意したものとみなされます。",
                "empty_deck": "この周辺にはもう誰もいません！",
                "empty_deck_desc": "技術スタックを編集するか、デッキを更新して新しいプロフィールを見つけることができます。",
                "refresh_deck": "デッキを更新",
                "pass": "スキップ",
                "like": "いいね",
                "compatibility": "マッチ度",
                "target": "目標",
                "match_title": "マッチング成立！",
                "match_desc": "お互いにマッチしました。",
                "match_send_message": "メッセージを送る",
                "match_continue": "スワイプを続ける",
                "connections": "つながり",
                "new_matches": "新しいマッチ",
                "no_messages": "メッセージはまだありません",
                "no_messages_desc": "「発見」画面から気になる開発者とマッチして、チャットを開始できます。",
                "coffee_chat_invite": "コーヒーに誘う",
                "coffee_chat_title": "コーヒーチャットへの招待",
                "coffee_chat_plan": "コーヒーチャットを計画",
                "date_and_time": "日時",
                "cancel": "キャンセル",
                "send_invite": "招待を送る",
                "profile_info": "プロフィール情報",
                "display_name": "表示名",
                "role": "役割 / 職名",
                "sector": "セクター",
                "experience": "経験年数",
                "years": "年",
                "what_looking_for": "何を求めていますか？",
                "bio": "自己紹介 (最大300文字)",
                "tech_stack": "マイ技術スタック",
                "add_tech": "技術を追加 (例: Golang)",
                "save_profile": "プロフィールを保存",
                "success": "成功",
                "profile_saved_desc": "プロフィール情報が正常に更新されました。",
                "theme": "テーマ",
                "language": "言語",
                "cancel_sub": "サブスクリプションをキャンセル (デモ)",
                "pro_desc_active": "プレミアム会員が有効です！",
                "pro_desc_inactive": "無制限のスワイプとプロフィルター機能",
                "active": "有効",
                "upgrade": "アップグレード",
                "chat_placeholder": "メッセージを入力...",
                "chat_start_helper": "マッチしました！挨拶しましょう。",
                "save": "保存",
                "stepper_label": "年",
                "success_title": "成功",
                "onboarding_title_1": "開発者ネットワーク",
                "onboarding_desc_1": "開発者とデザイナーのための次世代ネットワーキングプラットフォーム。",
                "onboarding_title_2": "スマートマッチング",
                "onboarding_desc_2": "技術スタックと目標に基づいて、最も相性の良いプロフェッショナルを見つけます。",
                "onboarding_title_3": "コーヒーチャット",
                "onboarding_desc_3": "コーヒーチャットを計画して経験を共有したり、プロジェクトを立ち上げましょう。",
                "skip": "スキップ",
                "get_started": "始める",
                "next": "次へ",
                "signup_title": "新規登録",
                "complete_register": "登録を完了する",
                "continue_btn": "次へ",
                "example_name": "例：アメット",
                "email_address": "メールアドレス",
                "password": "パスワード",
                "github_username_verify": "GitHubユーザー名（IT認証）",
                "username_placeholder": "ユーザー名",
                "github_required_warning": "⚠️ 当プラットフォームはIT・技術関係者専用のため、有効なGitHubアカウントが必要です。",
                "example_role": "例：iOSデベロッパー",
                "city": "都市",
                "work_remotely": "リモートワーク",
                "add_tech_placeholder": "技術を追加（例：Swift）",
                "matching_goal": "マッチングの目的",
                "fill_all_info_error": "すべての情報を入力してください。",
                "fill_role_city_error": "役割と都市のフィールドを入力してください。",
                "add_at_least_one_tech_error": "少なくとも1つの技術を追加してください。",
                "login_title": "ログイン",
                "dont_have_account": "アカウントをお持ちでないですか？",
                "login_with_email": "メールでログイン",
                "or_text": "または",
                "fill_all_fields_error": "すべてのフィールドを入力してください。",
                "error_title": "エラー",
                "paywall_unlock_desc": "技術コミュニティでの特権をアンロックしましょう。",
                "unlimited_likes": "無制限のいいね",
                "unlimited_likes_desc": "1日10回の制限を解除し、好きなだけスワイプ。",
                "advanced_filters": "高度なフィルター",
                "advanced_filters_desc": "技術スタック、都市、経験年数でフィルタリング。",
                "rewind_title": "巻き戻し",
                "rewind_desc": "間違えてスワイプしたプロフィールを元に戻す。",
                "profile_boost": "プロフィールブースト",
                "profile_boost_desc": "ディスカバーで上位表示され、5倍早くマッチング。",
                "select_a_plan": "プランを選択",
                "monthly_plan": "月間プラン",
                "cancel_anytime": "いつでもキャンセル可能",
                "yearly_plan": "年間プラン",
                "yearly_savings_format": "%@ / 年 (40%%お得)",
                "popular_badge": "人気",
                "upgrade_to_pro": "PROにアップグレード",
                "restore_purchases": "購入履歴を復元",
                "terms_of_service": "利用規約",
                "congratulations": "おめでとうございます！",
                "pro_privileges_unlocked": "DevMatch PROの機能が解放されました！",
                "start_using": "利用を開始する",
                "processing": "処理中...",
                "no_subscriptions_found": "復元するサブスクリプションが見つかりません。",
                "delete_account_title": "アカウントの削除",
                "cancel_action": "キャンセル",
                "delete_confirm_action": "削除する",
                "delete_account_message": "アカウントを削除してもよろしいですか？この操作は取り消せず、すべてのマッチとチャットが削除されます。",
                "manage_subscription": "サブスクリプションの管理",
                "app_settings": "アプリ設定",
                "info_account_section": "情報とアカウント",
                "about_app": "アプリについて",
                "terms_of_use": "利用規約",
                "privacy_policy": "プライバシーポリシー",
                "contact_us": "お問い合わせ",
                "log_out": "ログアウト",
                "close_action": "閉じる",
                "about_app_desc": "DevMatchは、開発者や技術の専門家が共同プロジェクトやコーヒーチャット、メンターシップのためにマッチングできるプレミアムネットワークプラットフォームです。",
                "terms_use_1_title": "1. 許容される利用方法",
                "terms_use_1_desc": "DevMatchは、IT、ソフトウェア、および技術の専門家向けにのみ設計されています。虚偽のプロフィールの作成や、他のユーザーへの嫌がらせは固く禁じられています。",
                "terms_use_2_title": "2. アカウントの責任",
                "terms_use_2_desc": "ユーザーは自身のアカウントのセキュリティと活動に責任を負います。認証されたGitHubアカウントが必要です。",
                "terms_use_3_title": "3. サブスクリプション規約",
                "terms_use_3_desc": "DevMatch PROのサブスクリプションはApple App Storeまたは統合決済を通じて請求され、解約されるまで自動更新されます。",
                "privacy_1_title": "1. 収集されるデータ",
                "privacy_1_desc": "入力されたメール、表示名、役割、経験、都市、自己紹介、およびプロフィール写真は、PostgreSQLデータベースに安全に保存されます。",
                "privacy_2_title": "2. GitHubとの連携",
                "privacy_2_desc": "認証のためにGitHubユーザー名が照会されます。GitHubのパスワードや機密情報を要求または保存することは決してありません。",
                "privacy_3_title": "3. データのセキュリティ",
                "privacy_3_desc": "パスワードはBCryptアルгоリズムを使用して暗号化ハッシュ化されます。個人データが第三者と共有されることはありません。",
                "contact_desc": "サポートへのリクエスト、ご質問、またはコラボレーションの提案については、お気軽にお問い合わせください。",
                "gender": "性別",
                "preferred_gender": "希望する性別",
                "like_limit_exceeded_title": "1日のいいね上限に達しました",
                "like_limit_exceeded_desc": "1日最大10回までいいねできます。無制限のいいねにはDevMatch PROにアップグレードしてください！"
            ],
            .russian: [
                "discover": "Знакомства",
                "messages": "Сообщения",
                "profile": "Мой Профиль",
                "login_desc": "Войдите, чтобы начать искать профессиональные контакты.",
                "login_github": "Войти через GitHub",
                "login_apple": "Войти через Apple",
                "login_guest": "Войти как гость",
                "login_terms": "Входя в приложение, вы принимаете Условия использования и Политику конфиденциальности.",
                "empty_deck": "Вокруг никого нет!",
                "empty_deck_desc": "Вы можете найти новые профили, изменив свой стек технологий или обновив список.",
                "refresh_deck": "Обновить список",
                "pass": "ПРОПУСТИТЬ",
                "like": "НРАВИТСЯ",
                "compatibility": "Совместимость",
                "target": "Цель",
                "match_title": "СВЯЗЬ УСТАНОВЛЕНА!",
                "match_desc": "Вы оба проявили взаимный интерес.",
                "match_send_message": "Написать сообщение",
                "match_continue": "Искать дальше",
                "connections": "Мои Контакты",
                "new_matches": "Новые пары",
                "no_messages": "Сообщений нет",
                "no_messages_desc": "Вы можете начать диалог после совпадения на вкладке поиска.",
                "coffee_chat_invite": "Пригласить на кофе",
                "coffee_chat_title": "Приглашение на кофе-чат",
                "coffee_chat_plan": "Запланировать встречу",
                "date_and_time": "Дата и время",
                "cancel": "Отмена",
                "send_invite": "Отправить приглашение",
                "profile_info": "Информация Профиля",
                "display_name": "Имя пользователя",
                "role": "Роль / Должность",
                "sector": "Сектор",
                "experience": "Опыт работы",
                "years": "Лет",
                "what_looking_for": "Что вы ищете?",
                "bio": "О себе (макс. 300 символов)",
                "tech_stack": "Мой Стек Технологий",
                "add_tech": "Добавить технологию (напр. Golang)",
                "save_profile": "Сохранить профиль",
                "success": "Успешно",
                "profile_saved_desc": "Ваш профиль был успешно обновлен.",
                "theme": "Тема оформления",
                "language": "Язык приложения",
                "cancel_sub": "Отменить подписку (Демо)",
                "pro_desc_active": "Ваша Premium-подписка активна!",
                "pro_desc_inactive": "Безлимитные лайки и профессиональные фильтры",
                "active": "Активно",
                "upgrade": "Обновить",
                "chat_placeholder": "Введите сообщение...",
                "chat_start_helper": "У вас совпадение! Скажите привет.",
                "save": "Сохранить",
                "stepper_label": "Лет",
                "success_title": "Успешно",
                "onboarding_title_1": "Сеть для Разработчиков",
                "onboarding_desc_1": "Сеть нового поколения для разработчиков, дизайнеров и IT-специалистов.",
                "onboarding_title_2": "Умный подбор",
                "onboarding_desc_2": "Находите наиболее совместимых специалистов на основе стека и ваших целей.",
                "onboarding_title_3": "Встречи за кофе",
                "onboarding_desc_3": "Планируйте кофе-встречи, чтобы делиться опытом или создавать совместные проекты.",
                "skip": "Пропустить",
                "get_started": "Начать",
                "next": "Далее",
                "signup_title": "Регистрация",
                "complete_register": "Завершить регистрацию",
                "continue_btn": "Продолжить",
                "example_name": "например, Ахмет",
                "email_address": "Адрес эл. почты",
                "password": "Пароль",
                "github_username_verify": "Имя пользователя GitHub (IT-верификация)",
                "username_placeholder": "Ваше имя пользователя",
                "github_required_warning": "⚠️ Поскольку наша платформа открыта только для специалистов в сфере IT, требуется действующий аккаунт GitHub.",
                "example_role": "например, iOS-разработчик",
                "city": "Город",
                "work_remotely": "Работаю удаленно",
                "add_tech_placeholder": "Добавить технологию (например, Swift)",
                "matching_goal": "Цель поиска",
                "fill_all_info_error": "Пожалуйста, заполните всю информацию.",
                "fill_role_city_error": "Пожалуйста, заполните поля роли и города.",
                "add_at_least_one_tech_error": "Пожалуйста, добавьте хотя бы одну технологию.",
                "login_title": "Войти",
                "dont_have_account": "Нет аккаунта?",
                "login_with_email": "Войти через эл. почту",
                "or_text": "или",
                "fill_all_fields_error": "Пожалуйста, заполните все поля.",
                "error_title": "Ошибка",
                "paywall_unlock_desc": "Разблокируйте привилегии в IT-сообществе.",
                "unlimited_likes": "Безлимитные лайки",
                "unlimited_likes_desc": "Снимите лимит в 10 лайков, листайте сколько хотите.",
                "advanced_filters": "Расширенные фильтры",
                "advanced_filters_desc": "Фильтр по стеку технологий, городу и опыту работы.",
                "rewind_title": "Назад",
                "rewind_desc": "Мгновенно возвращайте профили, пропущенные случайно.",
                "profile_boost": "Буст профиля",
                "profile_boost_desc": "Показывайтесь первыми в ленте для 5-кратного ускорения матчей.",
                "select_a_plan": "Выберите тариф",
                "monthly_plan": "Месячный план",
                "cancel_anytime": "Отмена в любое время",
                "yearly_plan": "Годовой план",
                "yearly_savings_format": "%@ в год (Скидка 40%%)",
                "popular_badge": "ПОПУЛЯРНО",
                "upgrade_to_pro": "ОБНОВИТЬ ДО PRO",
                "restore_purchases": "Восстановить покупки",
                "terms_of_service": "Условия использования",
                "congratulations": "ПОЗДРАВЛЯЕМ!",
                "pro_privileges_unlocked": "Привилегии DevMatch PRO разблокированы!",
                "start_using": "Начать использовать",
                "processing": "Обработка...",
                "no_subscriptions_found": "Подписки для восстановления не найдены.",
                "delete_account_title": "Удалить аккаунт",
                "cancel_action": "Отмена",
                "delete_confirm_action": "Да, удалить",
                "delete_account_message": "Вы уверены, что хотите удалить аккаунт? Это действие необратимо, все совпадения и чаты будут удалены.",
                "manage_subscription": "Управление подпиской",
                "app_settings": "Настройки приложения",
                "info_account_section": "Информация и аккаунт",
                "about_app": "О приложении",
                "terms_of_use": "Условия использования",
                "privacy_policy": "Политика конфиденциальности",
                "contact_us": "Связаться с нами",
                "log_out": "Выйти",
                "close_action": "Закрыть",
                "about_app_desc": "DevMatch — это премиум-платформа для нетворкинга разработчиков и IT-специалистов для поиска партнеров по проектам, кофе-встреч или менторства.",
                "terms_use_1_title": "1. Допустимое использование",
                "terms_use_1_desc": "DevMatch разработан исключительно для профессионалов сферы IT и технологий. Создание фейковых профилей или домогательства строго запрещены.",
                "terms_use_2_title": "2. Ответственность за аккаунт",
                "terms_use_2_desc": "Пользователи несут ответственность за безопасность своего аккаунта. Требуется верифицированный аккаунт GitHub.",
                "terms_use_3_title": "3. Условия подписки",
                "terms_use_3_desc": "Подписка DevMatch PRO оплачивается через Apple App Store или интегрированные методы оплаты и автоматически продлевается до отмены.",
                "privacy_1_title": "1. Собираемые данные",
                "privacy_1_desc": "Адрес электронной почты, имя пользователя, роль, опыт, город, биография и фотографии профиля надежно хранятся в нашей базе данных PostgreSQL.",
                "privacy_2_title": "2. Интеграция с GitHub",
                "privacy_2_desc": "Ваше имя пользователя GitHub проверяется для верификации. Мы никогда не запрашиваем и не храним ваши учетные данные GitHub.",
                "privacy_3_title": "3. Безопасность данных",
                "privacy_3_desc": "Пароли хэшируются с использованием криптографических алгоритмов BCrypt. Ваши личные данные никогда не передаются третьим лицам.",
                "contact_desc": "По любым вопросам поддержки, сотрудничества или предложений, пожалуйста, обращайтесь по электронной почте.",
                "gender": "Пол",
                "preferred_gender": "Предпочитаемый пол",
                "like_limit_exceeded_title": "Дневной лимит лайков исчерпан",
                "like_limit_exceeded_desc": "Вы можете ставить до 10 лайков в день. Обновитесь до DevMatch PRO для безлимитных лайков!"
            ]
        ]
        return translations[lang]?[key] ?? key
    }
}


