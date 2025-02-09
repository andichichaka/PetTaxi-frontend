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
                HomePageView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(Tab.home)
                
                if roleManager.userRole == "admin" {
                    Button(action: {
                        isCreatePostActive = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.color3).shadow(radius: 4))
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
                
                ProfilePage()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(Tab.profile)
            }
            .accentColor(.white)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.color3.opacity(0.7))
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.color3.opacity(0.7))]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.color3)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.color3)]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    NavigationBarView()
}
