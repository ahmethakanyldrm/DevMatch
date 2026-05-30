import SwiftUI

struct SplashView: View {
    @Binding var flowState: AppFlowState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var dataService = MockDataService.shared
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var glowOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Elegant dark gradient background (always dark/sleek for splash)
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.03, blue: 0.08), Color(red: 0.08, green: 0.08, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glowing background element
            Circle()
                .fill(LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
                .frame(width: 250, height: 250)
                .blur(radius: 60)
                .opacity(glowOpacity * 0.4)
            
            VStack(spacing: 24) {
                // Animated Glowing Logo
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple.opacity(0.8), .blue.opacity(0.8), .pink.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: "personalhotspot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 65, height: 65)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .blue.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.pink)
                        .offset(x: 35, y: -35)
                        .shadow(color: .pink, radius: 4)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // App Title
                VStack(spacing: 8) {
                    Text("TechConnect")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9), .purple.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(2)
                    
                    Text(dataService.appLanguage == .turkish ? "Geliştiriciler İçin Bağlantı Ağı" : "Professional Developer Network")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1)
                }
                .opacity(opacity)
                .offset(y: opacity == 1.0 ? 0 : 20)
            }
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
