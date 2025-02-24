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
                LiveBlurryBackground()
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 16) {
                        Spacer()
                            .frame(height: 120)

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

                VStack {
                    HStack {
                        HStack(alignment: .center, spacing: -10) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)

                            Text("PetTaxi")
                                .font(.custom("LilitaOne", size: 28))
                                .foregroundColor(.white)
                        }

                        Spacer()

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
                    .zIndex(1)

                    Spacer()
                }

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
                        .zIndex(2)
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

#Preview {
    HomePageView()
}
