import SwiftUI
import PhotosUI

struct ProfilePage: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditingInfo = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showConfirmationDialog = false
    @State private var pendingProfilePicture: UIImage? = nil
    @State private var backupProfile: ProfileBackup? = nil
    @State private var selectedPost: Post?
    @State private var showEditPostView = false
    @State private var navigateToAuth = false
    @StateObject private var roleManager = RoleManager()

    var body: some View {
        NavigationStack {
            ZStack {
                LiveBlurryBackground()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .font(.custom("Vollkorn-Bold", size: 18))
                        .foregroundColor(.color)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            profilePictureSection
                            
                            editInfoButton
                            
                            profileInfoFields
                            
                            if isEditingInfo {
                                saveProfileButton
                            }
                            
                            if !viewModel.userPosts.isEmpty {
                                Text("Your Posts")
                                    .font(.custom("Vollkorn-Bold", size: 24))
                                    .foregroundColor(.color)
                                    .padding(.top, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 16) {
                                    ForEach(viewModel.userPosts, id: \.id) { post in
                                        ZStack(alignment: .top) {
                                            PostView(post: post)
                                                .frame(width: 400, height: 480)
                                                .background(.color2)
                                                .cornerRadius(15)
                                                .shadow(radius: 5)
                                            
                                            HStack {
                                                Button(action: {
                                                    selectedPost = post
                                                    showEditPostView = true
                                                }) {
                                                    Image(systemName: "pencil.circle.fill")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.color3)
                                                        .padding(8)
                                                        .background(Color.white.opacity(0.8))
                                                        .clipShape(Circle())
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    deletePost(post)
                                                }) {
                                                    Image(systemName: "trash.circle.fill")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.red)
                                                        .padding(8)
                                                        .background(Color.white.opacity(0.8))
                                                        .clipShape(Circle())
                                                }
                                            }
                                            .padding(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                Text("No posts yet.")
                                    .font(.custom("Vollkorn-Medium", size: 16))
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: RequestedBookingsView()) {
                                Text(roleManager.userRole == "admin" ? "Requested Bookings" : "Approved Requests")
                                    .font(.custom("Vollkorn-Bold", size: 18))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.color3)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                                                        
                            logoutButton
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchProfile()
            }
            .fullScreenCover(item: $selectedPost) { post in
                PostDetailEditView(post: post, viewModel: viewModel)
                    .onDisappear {
                        viewModel.fetchProfile()
                    }
            }
            .navigationDestination(isPresented: $navigateToAuth) {
                AuthView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    private func deletePost(_ post: Post) {
        viewModel.deletePost(postId: post.id)
    }

    // MARK: - Subviews

    private var profilePictureSection: some View {
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

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Circle()
                    .fill(Color.color3)
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
    }

    private var editInfoButton: some View {
        Button(action: {
            if isEditingInfo {
                restoreBackup()
            } else {
                createBackup()
            }
            isEditingInfo.toggle()
        }) {
            HStack {
                Image(systemName: isEditingInfo ? "xmark.circle.fill" : "pencil.circle.fill")
                Text(isEditingInfo ? "Exit" : "Edit Profile")
            }
            .font(.custom("Vollkorn-Bold", size: 18))
            .foregroundColor(isEditingInfo ? .gray : .color3)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }

    private var profileInfoFields: some View {
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
            EnhancedDescriptionFieldView(
                description: Binding(
                    get: { viewModel.description ?? "" },
                    set: { viewModel.description = $0 }
                ),
                isEditable: isEditingInfo
            )
        }
        .padding(.horizontal)
    }

    private var saveProfileButton: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.saveProfileInfo()
            }
            isEditingInfo.toggle()
        }) {
            Text("Save Profile")
                .font(.custom("Vollkorn-Bold", size: 18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.color3)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
    
    private var logoutButton: some View {
            Button(action: {
                TokenManager.shared.deleteTokens()
                navigateToAuth = true
            }) {
                Text("Log Out")
                    .font(.custom("Vollkorn-Bold", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
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

// MARK: - EditableFieldView
struct EditableFieldView: View {
    let label: String
    @Binding var value: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.custom("Vollkorn-Medium", size: 14))
                .foregroundColor(.white)
            if isEditable {
                TextField("", text: $value)
                    .font(.custom("Vollkorn-Regular", size: 16))
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            } else {
                Text(value)
                    .font(.custom("Vollkorn-Regular", size: 16))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
        }
    }
}

// MARK: - EnhancedDescriptionFieldView
struct EnhancedDescriptionFieldView: View {
    @Binding var description: String
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.custom("Vollkorn-Medium", size: 14))
                .foregroundColor(.white)

            if isEditable {
                TextField("Add description", text: $description)
                    .font(.custom("Vollkorn-Regular", size: 16))
                    .padding(8)
                    .frame(minHeight: 120)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            } else {
                Text(description.isEmpty ? "Add description" : description)
                    .font(.custom("Vollkorn-Regular", size: 16))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 120)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    ProfilePage()
}
