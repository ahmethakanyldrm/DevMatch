//
//  TechConnectAppApp.swift
//  TechConnectApp
//
//  Created by Ahmet Hakan Yıldırım on 30.05.2026.
//

import SwiftUI

@main
struct TechConnectAppApp: App {
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
