import SwiftUI

struct SplashView: View {
    @Binding var flowState: AppFlowState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dataService = MockDataService.shared
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Image("splash_bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            // Animate in
            withAnimation(.easeOut(duration: 1.2)) {
                scale = 1.0
                opacity = 1.0
                glowOpacity = 1.0
            }
            
            // Wait and transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                if APIService.shared.isLoggedIn {
                    Task {
                        await MockDataService.shared.fetchAllData()
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                flowState = .main
                            }
                        }
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if hasCompletedOnboarding {
                            flowState = .login
                        } else {
                            flowState = .onboarding
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView(flowState: .constant(.splash))
}
