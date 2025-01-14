//
//  ProfilePage.swift
//  PetTaxi
//
//  Created by Andrey on 2.01.25.
//

import SwiftUI
import PhotosUI

struct ProfilePage: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditingInfo = false
    @State private var selectedItem: PhotosPickerItem? // For PhotosPicker
    @State private var showConfirmationDialog = false // For confirmation dialog
    @State private var pendingProfilePicture: UIImage? = nil // Temp profile picture
    @State private var backupProfile: ProfileBackup? = nil // Backup for unsaved changes

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Profile Picture Section
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 128, height: 128)
                                .shadow(radius: 10)

                            if let profileImage = viewModel.profilePicture {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }

                            // PhotosPicker Button
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Circle()
                                    .fill(Color.yellow)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                    )
                                    .shadow(radius: 5)
                            }
                            .offset(x: 45, y: 45)
                            .onChange(of: selectedItem) { newItem in
                                if let newItem = newItem {
                                    Task {
                                        if let data = try? await newItem.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                            pendingProfilePicture = uiImage
                                            showConfirmationDialog = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 40)

                        // Confirmation Dialog
                        .confirmationDialog("Are you sure you want to change your profile picture?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                            Button("Yes") {
                                if let newPicture = pendingProfilePicture {
                                    viewModel.profilePicture = newPicture
                                    viewModel.updateProfilePicture()
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                pendingProfilePicture = nil
                            }
                        }

                        // Edit Info Button
                        Button(action: {
                            if isEditingInfo {
                                restoreBackup() // Restore backup if exiting without saving
                            } else {
                                createBackup() // Create backup when starting to edit
                            }
                            isEditingInfo.toggle()
                        }) {
                            HStack {
                                Image(systemName: isEditingInfo ? "xmark.circle.fill" : "pencil.circle.fill")
                                Text(isEditingInfo ? "Exit" : "Edit Profile")
                            }
                            .foregroundColor(isEditingInfo ? .gray : .yellow)
                            .font(.headline)
                        }
                        .padding()

                        // Profile Info Fields
                        Group {
                            EditableFieldView(
                                label: "Username",
                                value: $viewModel.username,
                                isEditable: isEditingInfo
                            )
                            EditableFieldView(
                                label: "Email",
                                value: $viewModel.email,
                                isEditable: isEditingInfo
                            )
                            // Enhanced Description Field
                            EnhancedDescriptionFieldView(
                                description: Binding(
                                    get: { viewModel.description ?? "" },
                                    set: { viewModel.description = $0 }
                                ),
                                isEditable: isEditingInfo
                            )
                        }
                        .padding(.horizontal)

                        // Save Profile Button (Visible only in Edit Mode)
                        if isEditingInfo {
                            Button(action: {
                                viewModel.saveProfileInfo()
                                isEditingInfo.toggle()
                            }) {
                                Text("Save Profile")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.yellow)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchProfile()
        }
    }

    // MARK: - Backup Methods
    private func createBackup() {
        backupProfile = ProfileBackup(username: viewModel.username, email: viewModel.email, description: viewModel.description)
    }

    private func restoreBackup() {
        guard let backup = backupProfile else { return }
        viewModel.username = backup.username
        viewModel.email = backup.email
        viewModel.description = backup.description
    }
}

// MARK: - Profile Backup Struct
struct ProfileBackup {
    let username: String
    let email: String
    let description: String?
}



struct EditableFieldView: View {
    let label: String
    @Binding var value: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            if isEditable {
                TextField("", text: $value)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            } else {
                Text(value)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
        }
    }
}

struct EnhancedDescriptionFieldView: View {
    @Binding var description: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.caption)
                .foregroundColor(.gray)

            if isEditable {
                // Editable TextEditor for Description
                TextField("Add description", text: $description)
                    .padding(8)
                    .frame(minHeight: 120) // Larger height for better usability
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                // Read-only Description
                Text(description.isEmpty ? "Add description" : description)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 120) // Matches TextEditor height
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.top, 8)
    }
}

#Preview{
    ProfilePage()
}
