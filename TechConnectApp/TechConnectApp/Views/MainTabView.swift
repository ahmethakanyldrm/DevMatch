import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var dataService = MockDataService.shared
    
    // Configure dynamic tab bar appearance to respect Light/Dark theme natively
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // automatically adjusts to light/dark system settings
        
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
                    Label(
                        Localization.string("discover", lang: dataService.appLanguage),
                        systemImage: "sparkles"
                    )
                }
                .tag(0)
            
            ChatsListView()
                .tabItem {
                    Label(
                        Localization.string("messages", lang: dataService.appLanguage),
                        systemImage: "bubble.left.and.bubble.right.fill"
                    )
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label(
                        Localization.string("profile", lang: dataService.appLanguage),
                        systemImage: "person.crop.circle.fill"
                    )
                }
                .tag(2)
        }
        .tint(.purple)
    }
}

#Preview {
    MainTabView()
}
