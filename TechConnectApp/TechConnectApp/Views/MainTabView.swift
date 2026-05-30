import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Configure standard dark tab bar appearance on iOS
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        
        // Unselected item tint
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        // Selected item tint
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemPurple
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPurple]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView()
                .tabItem {
                    Label("Keşfet", systemImage: "sparkles")
                }
                .tag(0)
            
            ChatsListView()
                .tabItem {
                    Label("Mesajlar", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profilim", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
        }
        .tint(.purple)
    }
}

#Preview {
    MainTabView()
}
