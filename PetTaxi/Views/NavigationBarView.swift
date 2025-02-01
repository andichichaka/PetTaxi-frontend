import SwiftUI

struct NavigationBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var isCreatePostActive: Bool = false
    @StateObject private var roleManager = RoleManager()
    
    enum Tab {
        case home
        case profile
        case createPost
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                HomePageView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                // Create Post Tab (Conditional for Admin)
                if roleManager.userRole == "admin" {
                    Button(action: {
                        isCreatePostActive = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.color3).shadow(radius: 4)) // Mint Green
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(y: -20)
                    .fullScreenCover(isPresented: $isCreatePostActive) {
                        CreatePostView(isActive: $isCreatePostActive)
                    }
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Post")
                    }
                    .tag(Tab.createPost)
                }
                
                // Profile Tab
                ProfilePage()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
            }
            .accentColor(.white) // Set the selected tab icon and text color to white
            .onAppear {
                // Customize the appearance of the tab bar
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white.withAlphaComponent(0.8) // Semi-transparent black
                
                // Unselected icon and text color
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.color3.opacity(0.7)) // Mint Green (lighter)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.color3.opacity(0.7))] // Mint Green (lighter)
                
                // Selected icon and text color
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.color3) // Mint Green
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.color3)] // Mint Green
                
                // Apply the appearance
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    NavigationBarView()
}
