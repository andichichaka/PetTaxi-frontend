//
//  HomePageView.swift
//  PetTaxi
//
//  Created by Andrey on 24.12.24.
//

import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showProfilePictureDialog = false
    @State private var showRoleSelectionDialog = false
    @State private var isUploading = false
    @State private var uploadErrorMessage: String? = nil
    @State private var showSearchFilter = false // State for SearchFilterView

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .disabled(showRoleSelectionDialog)

                VStack {
                    // Top Bar
                    HStack {
                        Text("PetTaxi")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            showSearchFilter = true // Show the SearchFilterView
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))

                    // Post List
                    if viewModel.posts.isEmpty {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding()
                        } else {
                            ProgressView("Loading posts...")
                                .padding()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.posts) { post in
                                    PostView(post: post)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .disabled(showRoleSelectionDialog)
                
                if showProfilePictureDialog {
                    ProfilePictureDialog(isActive: $showProfilePictureDialog) {
                        // Action on successful upload
                        print("Profile picture uploaded successfully.")
                        showRoleSelectionDialog = true
                    } skipAction: {
                        // Skip action
                        print("User skipped profile picture upload.")
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
                        .zIndex(1)
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
