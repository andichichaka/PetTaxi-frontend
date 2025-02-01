import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showProfilePictureDialog = false
    @State private var showRoleSelectionDialog = false
    @State private var isUploading = false
    @State private var uploadErrorMessage: String? = nil
    @State private var showSearchFilter = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Live Blurry Background (without scroll interaction)
                LiveBlurryBackground()
                    .edgesIgnoringSafeArea(.all)

                // Post List (Scrolls behind the top bar)
                ScrollView {
                    VStack(spacing: 16) {
                        // Add padding to the top to account for the floating top bar
                        Spacer()
                            .frame(height: 120) // Adjust this value to match the top bar height

                        // Posts
                        if viewModel.posts.isEmpty {
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                            } else {
                                ProgressView("Loading posts...")
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        } else {
                            ForEach(viewModel.posts) { post in
                                PostView(post: post)
                            }
                        }
                    }
                    .padding(.vertical)
                }

                // Floating Top Bar
                VStack {
                    HStack {
                        // App Logo and Name
                        HStack(alignment: .center, spacing: -10) {
                            Image("AppLogo") // Use the logo from Assets.xcassets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)

                            Text("PetTaxi")
                                .font(.custom("LilitaOne", size: 28))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // Search Button
                        Button(action: {
                            showSearchFilter = true
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .zIndex(1) // Ensure the top bar stays above the posts

                    Spacer() // Push the top bar to the top
                }

                // Dialogs and Modals
                if showProfilePictureDialog {
                    ProfilePictureDialog(isActive: $showProfilePictureDialog) {
                        showRoleSelectionDialog = true
                    } skipAction: {
                        showRoleSelectionDialog = true
                    }
                    .onDisappear {
                        showRoleSelectionDialog = true
                    }
                }

                if showRoleSelectionDialog {
                    RoleSelectionDialog(isActive: $showRoleSelectionDialog)
                }

                if showSearchFilter {
                    SearchFilterView(isActive: $showSearchFilter)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            Color.black.opacity(0.3)
                                .edgesIgnoringSafeArea(.all)
                        )
                        .transition(.opacity)
                        .zIndex(2) // Ensure the search filter is above everything
                }
            }
            .onAppear {
                viewModel.fetchPosts()

                if UserDefaults.standard.bool(forKey: "showProfileDialog") {
                    showProfilePictureDialog = true
                    UserDefaults.standard.set(false, forKey: "showProfileDialog")
                }
            }
        }
    }
}

// Live Blurry Background with Self-Moving Bubbles (No Scroll Interaction)
struct LiveBlurryBackground: View {
    @State private var bubbleOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.8), Color.color.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // Self-Moving Bubbles
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: CGFloat.random(in: 50..<150), height: CGFloat.random(in: 50..<150))
                    .position(
                        x: CGFloat.random(in: 0..<UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0..<UIScreen.main.bounds.height)
                    )
                    .offset(x: bubbleOffset, y: 0) // Move on its own
                    .animation(
                        Animation.easeInOut(duration: 4).repeatForever(autoreverses: true),
                        value: bubbleOffset
                    )
            }
        }
        .blur(radius: 10) // Blur the entire background
        .onAppear {
            bubbleOffset = 20 // Initial bubble movement
        }
    }
}

#Preview {
    HomePageView()
}
