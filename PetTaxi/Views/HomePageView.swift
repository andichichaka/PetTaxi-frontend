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
        @State private var isUploading = false
        @State private var uploadErrorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Top Bar
                    HStack {
                        Text("PetTaxi")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            print("Search tapped")
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

                    // Bottom Navigation Bar
                    HStack {
                        Button(action: {
                            print("Home tapped")
                        }) {
                            VStack {
                                Image(systemName: "house.fill")
                                    .font(.title2)
                                Text("Home")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                        Button(action: {
                            print("Profile tapped")
                        }) {
                            VStack {
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                Text("Profile")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                }
                
                                if showProfilePictureDialog {
                                    ProfilePictureDialog(isActive: $showProfilePictureDialog) {
                                        // Action on successful upload
                                        print("Profile picture uploaded successfully.")
                                    } skipAction: {
                                        // Skip action
                                        print("User skipped profile picture upload.")
                                    }
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

#Preview{
    HomePageView()
}
