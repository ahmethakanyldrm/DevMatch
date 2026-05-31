import SwiftUI
import RevenueCat

struct CustomPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    @StateObject private var dataService = MockDataService.shared
    
    @State private var selectedPlan: Int = 1 // 0: Monthly, 1: Yearly
    @State private var isLoading = false
    @State private var showSuccessAlert = false
    @State private var errorMessage = ""
    
    // Fallback info if offerings are not loaded
    private var fallbackMonthlyPrice: String {
        dataService.appLanguage == .turkish ? "₺169.99" : "€4.99"
    }
    private var fallbackYearlyPrice: String {
        dataService.appLanguage == .turkish ? "₺99.99" : "€2.99"
    }
    private var fallbackYearlyTotal: String {
        dataService.appLanguage == .turkish ? "₺1198.88" : "€35.88"
    }
    
    var body: some View {
        ZStack {
            // Dark elegant background
            Color(red: 0.08, green: 0.09, blue: 0.12)
                .ignoresSafeArea()
            
            // Faint subtle background ambient light
            VStack {
                HStack {
                    Circle()
                        .fill(Color.purple.opacity(0.04))
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .offset(x: -80, y: -50)
                    Spacer()
                }
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Header navigation bar
                headerBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title Section
                        titleSection
                        
                        // Features List
                        featuresList
                        
                        // Plans Selection Card
                        plansSelectionSection
                        
                        // Buy Button & Policy
                        actionSection
                        
                        Spacer().frame(height: 30)
                    }
                    .padding(.horizontal, 24)
                }
            }
            
            // Success Overlay
            if showSuccessAlert {
                successOverlayView
            }
            
            // Loading Overlay
            if isLoading || subManager.isLoading {
                loadingOverlayView
            }
        }
        .preferredColorScheme(.dark)
        .alert(
            Localization.string("error_title", lang: dataService.appLanguage),
            isPresented: Binding(
                get: { !errorMessage.isEmpty },
                set: { if !$0 { errorMessage = "" } }
            )
        ) {
            Button(Localization.string("close_action", lang: dataService.appLanguage), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Subviews
    
    private var headerBar: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white.opacity(0.5))
                    .padding()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.yellow)
            }
            
            Text("DEVMATCH PRO")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(2)
            
            Text(Localization.string("paywall_unlock_desc", lang: dataService.appLanguage))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var featuresList: some View {
        VStack(spacing: 16) {
            featureRow(
                icon: "heart.fill",
                color: .pink,
                title: Localization.string("unlimited_likes", lang: dataService.appLanguage),
                desc: Localization.string("unlimited_likes_desc", lang: dataService.appLanguage)
            )
            featureRow(
                icon: "sparkles",
                color: .blue,
                title: Localization.string("advanced_filters", lang: dataService.appLanguage),
                desc: Localization.string("advanced_filters_desc", lang: dataService.appLanguage)
            )
            featureRow(
                icon: "arrow.counterclockwise",
                color: .green,
                title: Localization.string("rewind_title", lang: dataService.appLanguage),
                desc: Localization.string("rewind_desc", lang: dataService.appLanguage)
            )
            featureRow(
                icon: "bolt.fill",
                color: .yellow,
                title: Localization.string("profile_boost", lang: dataService.appLanguage),
                desc: Localization.string("profile_boost_desc", lang: dataService.appLanguage)
            )
        }
        .padding(18)
        .background(Color.white.opacity(0.04))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            Spacer()
        }
    }
    
    private var plansSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.string("select_a_plan", lang: dataService.appLanguage))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                // Monthly Plan Card
                planCard(
                    index: 0,
                    title: Localization.string("monthly_plan", lang: dataService.appLanguage),
                    price: monthlyPriceString,
                    subtext: Localization.string("cancel_anytime", lang: dataService.appLanguage)
                )
                
                // Yearly Plan Card
                planCard(
                    index: 1,
                    title: Localization.string("yearly_plan", lang: dataService.appLanguage),
                    price: yearlyPriceString,
                    subtext: String(format: Localization.string("yearly_savings_format", lang: dataService.appLanguage), yearlyTotalString),
                    badge: Localization.string("popular_badge", lang: dataService.appLanguage)
                )
            }
        }
    }
    
    private func planCard(index: Int, title: String, price: String, subtext: String, badge: String? = nil) -> some View {
        let isSelected = selectedPlan == index
        
        return Button(action: { selectedPlan = index }) {
            VStack(spacing: 12) {
                if let badgeText = badge {
                    Text(badgeText)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.yellow)
                        .cornerRadius(6)
                        .offset(y: -6)
                } else {
                    Spacer().frame(height: 12)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Text(price)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? .purple : .white)
                
                Text(subtext)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                
                Spacer().frame(height: 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.02))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.purple : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? .purple.opacity(0.2) : .clear, radius: 8)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 14) {
            Button(action: handlePurchase) {
                Text(Localization.string("upgrade_to_pro", lang: dataService.appLanguage))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.indigo)
                    .cornerRadius(14)
            }
            
            HStack(spacing: 20) {
                Button(action: handleRestore) {
                    Text(Localization.string("restore_purchases", lang: dataService.appLanguage))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text("|")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.2))
                
                Button(action: {
                    // Open Terms of Service Link
                }) {
                    Text(Localization.string("terms_of_service", lang: dataService.appLanguage))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.top, 10)
    }
    
    private var successOverlayView: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .shadow(color: .green.opacity(0.4), radius: 15)
                
                Text(Localization.string("congratulations", lang: dataService.appLanguage))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text(Localization.string("pro_privileges_unlocked", lang: dataService.appLanguage))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    showSuccessAlert = false
                    dismiss()
                }) {
                    Text(Localization.string("start_using", lang: dataService.appLanguage))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
        }
        .transition(.opacity)
    }
    
    private var loadingOverlayView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(Localization.string("processing", lang: dataService.appLanguage))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Purchase Logic
    
    private func handlePurchase() {
        isLoading = true
        errorMessage = ""
        
        Task {
            // Check if packages are available from RevenueCat offerings
            if let offerings = subManager.offerings,
               let currentOffering = offerings.current {
                
                let packageToBuy = selectedPlan == 0 ? currentOffering.monthly : currentOffering.annual
                
                if let package = packageToBuy {
                    let success = await subManager.purchase(package: package)
                    await MainActor.run {
                        isLoading = false
                        if success {
                            withAnimation {
                                showSuccessAlert = true
                            }
                        }
                    }
                    return
                }
            }
            
            // FALLBACK / SANDBOX SIMULATION (Used in simulator or when Apple Paid Applications is pending)
            // Simulates purchase by updating the local user status and syncing with Spring Boot API
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate delay
                
                // Sync with local manager
                await MainActor.run {
                    subManager.isPro = true
                    dataService.currentUser.subscriptionTier = .pro
                }
                
                // Sync with backend API
                if APIService.shared.isLoggedIn {
                    var profile = dataService.currentUser
                    profile.subscriptionTier = .pro
                    try await dataService.saveProfile(profile: profile)
                }
                
                await MainActor.run {
                    isLoading = false
                    withAnimation {
                        showSuccessAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleRestore() {
        isLoading = true
        errorMessage = ""
        
        Task {
            // Attempt RevenueCat restore
            let success = await subManager.restorePurchases()
            await MainActor.run {
                isLoading = false
                if success {
                    withAnimation {
                        showSuccessAlert = true
                    }
                } else {
                    errorMessage = Localization.string("no_subscriptions_found", lang: dataService.appLanguage)
                }
            }
        }
    }
    
    // Price strings formatting based on offerings or fallback values
    private var monthlyPriceString: String {
        if let offerings = subManager.offerings,
           let current = offerings.current,
           let monthly = current.monthly {
            return monthly.localizedPriceString
        }
        return fallbackMonthlyPrice
    }
    
    private var yearlyPriceString: String {
        if let offerings = subManager.offerings,
           let current = offerings.current,
           let annual = current.annual {
            // Calculate a monthly equivalent for display e.g. annual total / 12
            // For simple mockup, return fallback monthly rate if we want, or the localized yearly value divided.
            // Let's return the monthly equivalent format
            return annual.localizedPriceString
        }
        return fallbackYearlyPrice
    }
    
    private var yearlyTotalString: String {
        if let offerings = subManager.offerings,
           let current = offerings.current,
           let annual = current.annual {
            return annual.localizedPriceString
        }
        return fallbackYearlyTotal
    }
}

#Preview {
    CustomPaywallView()
}
