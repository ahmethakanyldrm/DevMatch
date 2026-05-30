import Foundation
import RevenueCat
import Combine

@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isPro = false
    @Published var offerings: Offerings? = nil
    @Published var isLoading = false
    @Published var purchaseError: Error? = nil
    
    private override init() {
        super.init()
        // Observe CustomerInfo changes
        Purchases.shared.delegate = self
        
        // Fetch current subscription status and offerings on startup
        Task {
            await updateSubscriptionStatus()
            await fetchOfferings()
        }
    }
    
    func updateSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.isPro = customerInfo.entitlements["pro"]?.isActive ?? false
            
            // Sync locally
            await MainActor.run {
                MockDataService.shared.currentUser.subscriptionTier = self.isPro ? .pro : .free
            }
        } catch {
            print("Error fetching customer info: \(error.localizedDescription)")
        }
    }
    
    func fetchOfferings() async {
        do {
            let offeringsList = try await Purchases.shared.offerings()
            self.offerings = offeringsList
        } catch {
            print("Error fetching offerings: \(error.localizedDescription)")
        }
    }
    
    func purchase(package: Package) async -> Bool {
        isLoading = true
        purchaseError = nil
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isLoading = false
            if !result.userCancelled {
                self.isPro = result.customerInfo.entitlements["pro"]?.isActive ?? false
                
                // Sync with local data service
                await MainActor.run {
                    MockDataService.shared.currentUser.subscriptionTier = self.isPro ? .pro : .free
                }
                
                // Sync with backend API
                if APIService.shared.isLoggedIn {
                    var profile = MockDataService.shared.currentUser
                    profile.subscriptionTier = self.isPro ? .pro : .free
                    try? await MockDataService.shared.saveProfile(profile: profile)
                }
                return true
            }
        } catch {
            isLoading = false
            self.purchaseError = error
            print("Purchase failed: \(error.localizedDescription)")
        }
        return false
    }
    
    func restorePurchases() async -> Bool {
        isLoading = true
        purchaseError = nil
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isLoading = false
            self.isPro = customerInfo.entitlements["pro"]?.isActive ?? false
            
            // Sync with local data service
            await MainActor.run {
                MockDataService.shared.currentUser.subscriptionTier = self.isPro ? .pro : .free
            }
            
            if APIService.shared.isLoggedIn {
                var profile = MockDataService.shared.currentUser
                profile.subscriptionTier = self.isPro ? .pro : .free
                try? await MockDataService.shared.saveProfile(profile: profile)
            }
            return self.isPro
        } catch {
            isLoading = false
            self.purchaseError = error
            print("Restore failed: \(error.localizedDescription)")
        }
        return false
    }
    
    // Set active App User ID when logging in
    func identifyUser(userId: UUID) {
        Purchases.shared.logIn(userId.uuidString) { [weak self] (customerInfo, created, error) in
            guard let self = self else { return }
            Task { @MainActor in
                if let info = customerInfo {
                    self.isPro = info.entitlements["pro"]?.isActive ?? false
                    MockDataService.shared.currentUser.subscriptionTier = self.isPro ? .pro : .free
                }
            }
        }
    }
    
    // Reset user when logging out
    func resetUser() {
        Purchases.shared.logOut { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            Task { @MainActor in
                self.isPro = false
                MockDataService.shared.currentUser.subscriptionTier = .free
            }
        }
    }
}

extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.isPro = customerInfo.entitlements["pro"]?.isActive ?? false
            MockDataService.shared.currentUser.subscriptionTier = self.isPro ? .pro : .free
            
            // Sync with backend if logged in
            if APIService.shared.isLoggedIn {
                var profile = MockDataService.shared.currentUser
                profile.subscriptionTier = self.isPro ? .pro : .free
                try? await MockDataService.shared.saveProfile(profile: profile)
            }
        }
    }
}
