//
//  TechConnectAppApp.swift
//  TechConnectApp
//
//  Created by Ahmet Hakan Yıldırım on 30.05.2026.
//

import SwiftUI

enum AppFlowState {
    case splash
    case onboarding
    case login
    case main
}

@main
struct TechConnectAppApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var flowState: AppFlowState = .splash
    @StateObject private var dataService = MockDataService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch flowState {
                case .splash:
                    SplashView(flowState: $flowState)
                case .onboarding:
                    OnboardingView(flowState: $flowState)
                case .login:
                    LoginView(isLoggedIn: Binding(
                        get: { false },
                        set: { loggedIn in
                            if loggedIn {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    flowState = .main
                                }
                            }
                        }
                    ))
                case .main:
                    MainTabView()
                }
            }
            .preferredColorScheme(dataService.appTheme.colorScheme)
        }
    }
}
