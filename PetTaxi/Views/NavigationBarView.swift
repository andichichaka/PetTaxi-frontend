import SwiftUI

struct NavigationBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var isCreatePostActive: Bool = false
    @StateObject private var roleManager = RoleManager()

    enum Tab {
        case home, createPost, profile
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                homeTab
                if roleManager.userRole == "admin" {
                    createPostTab
                }
                profileTab
            }
            .accentColor(AppStyle.Colors.light)
            .onAppear(perform: setupTabBarAppearance)
        }
    }

    // MARK: - Tabs

    private var homeTab: some View {
        HomePageView()
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)
    }

    private var createPostTab: some View {
        Button(action: { isCreatePostActive = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(AppStyle.Colors.light)
                .padding()
                .background(Circle().fill(AppStyle.Colors.accent).shadow(radius: 4))
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: -20)
        .fullScreenCover(isPresented: $isCreatePostActive) {
            CreatePostView(isActive: $isCreatePostActive)
        }
        .tabItem {
            Label("Create Post", systemImage: "plus.circle.fill")
        }
        .tag(Tab.createPost)
    }

    private var profileTab: some View {
        ProfilePage()
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(Tab.profile)
    }

    // MARK: - Appearance Setup

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppStyle.Colors.light.opacity(0.8))

        let normalColor = UIColor(AppStyle.Colors.accent.opacity(0.7))
        let selectedColor = UIColor(AppStyle.Colors.accent)

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    NavigationBarView()
}
