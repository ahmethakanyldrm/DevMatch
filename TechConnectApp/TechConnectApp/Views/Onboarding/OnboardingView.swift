import SwiftUI

struct OnboardingView: View {
    @Binding var flowState: AppFlowState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dataService = MockDataService.shared
    
    @State private var currentPage = 0
    
    // Struct representing each onboarding page
    struct OnboardingItem: Identifiable {
        let id = UUID()
        let titleKey: String
        let descKey: String
        let iconName: String
        let startColor: Color
        let endColor: Color
    }
    
    private let onboardingItems = [
        OnboardingItem(
            titleKey: "onboarding_title_1",
            descKey: "onboarding_desc_1",
            iconName: "network",
            startColor: .purple,
            endColor: .blue
        ),
        OnboardingItem(
            titleKey: "onboarding_title_2",
            descKey: "onboarding_desc_2",
            iconName: "rectangle.stack.person.crop.fill",
            startColor: .blue,
            endColor: .teal
        ),
        OnboardingItem(
            titleKey: "onboarding_title_3",
            descKey: "onboarding_desc_3",
            iconName: "cup.and.saucer.fill",
            startColor: .orange,
            endColor: .red
        )
    ]
    
    var body: some View {
        ZStack {
            // Elegant dark background matching splash & profile dark themes
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            // Subtle top corner glow
            Circle()
                .fill(onboardingItems[currentPage].startColor.opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -150, y: -200)
                .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            // Subtle bottom corner glow
            Circle()
                .fill(onboardingItems[currentPage].endColor.opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: 150, y: 200)
                .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack {
                // Header (Skip Button)
                HStack {
                    Spacer()
                    if currentPage < onboardingItems.count - 1 {
                        Button(action: finishOnboarding) {
                            Text(Localization.string("skip", lang: dataService.appLanguage))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                        }
                    } else {
                        // Invisible placeholder to keep layout consistent
                        Text("")
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Page Slider (Carousel)
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingItems.count, id: \.self) { index in
                        let item = onboardingItems[index]
                        
                        VStack(spacing: 40) {
                            // Icon container with dynamic gradient glow
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [item.startColor.opacity(0.2), item.endColor.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 180, height: 180)
                                    .shadow(color: item.startColor.opacity(0.3), radius: 25)
                                
                                Image(systemName: item.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, .white.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: item.startColor, radius: 10)
                            }
                            .scaleEffect(currentPage == index ? 1.0 : 0.85)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: currentPage)
                            
                            VStack(spacing: 16) {
                                // Title text
                                Text(Localization.string(item.titleKey, lang: dataService.appLanguage))
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                // Description text
                                Text(Localization.string(item.descKey, lang: dataService.appLanguage))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .lineSpacing(4)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Bottom control section
                VStack(spacing: 24) {
                    // Custom indicator dots
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingItems.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? onboardingItems[index].startColor : Color.white.opacity(0.2))
                                .frame(width: currentPage == index ? 16 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Main action button (Next or Start)
                    Button(action: nextButtonTapped) {
                        Text(
                            currentPage == onboardingItems.count - 1
                            ? Localization.string("get_started", lang: dataService.appLanguage)
                            : Localization.string("next", lang: dataService.appLanguage)
                        )
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [onboardingItems[currentPage].startColor, onboardingItems[currentPage].endColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: onboardingItems[currentPage].startColor.opacity(0.4), radius: 10, y: 5)
                        .padding(.horizontal, 24)
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    private func nextButtonTapped() {
        if currentPage < onboardingItems.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            finishOnboarding()
        }
    }
    
    private func finishOnboarding() {
        hasCompletedOnboarding = true
        withAnimation(.easeInOut(duration: 0.5)) {
            flowState = .login
        }
    }
}

#Preview {
    OnboardingView(flowState: .constant(.onboarding))
}
