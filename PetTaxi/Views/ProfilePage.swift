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
    @State private var errorMessage: String?
    @State private var postToDelete: Post?

    var body: some View {
        NavigationStack {
            ZStack {
                LiveBlurryBackground()

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .font(AppStyle.Fonts.vollkornBold(18))
                        .foregroundColor(AppStyle.Colors.base)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppStyle.Fonts.vollkornMedium(16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            profilePictureSection
                            editInfoButton
                            profileInfoFields
                            if isEditingInfo { errorTextSection; saveProfileButton }
                            userPostsSection
                            navigationLinksSection
                            logoutButton
                        }
                    }
                }
            }
            .onAppear { viewModel.fetchProfile() }
            .fullScreenCover(item: $selectedPost) { post in
                PostDetailEditView(post: post, viewModel: viewModel)
                    .onDisappear { viewModel.fetchProfile() }
            }
            .confirmationDialog("Are you sure you want to delete this post?", isPresented: Binding<Bool>(
                get: { postToDelete != nil },
                set: { if !$0 { postToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let post = postToDelete {
                        deletePost(post)
                        postToDelete = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    postToDelete = nil
                }
            }
            .navigationDestination(isPresented: $navigateToAuth) {
                AuthView().navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Subviews

    private var profilePictureSection: some View {
        ZStack {
            Circle().fill(.white).frame(width: 128, height: 128).shadow(radius: 10)

            if let image = viewModel.profilePicture {
                Image(uiImage: image)
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
                    .fill(AppStyle.Colors.accent)
                    .frame(width: 36, height: 36)
                    .overlay(Image(systemName: "camera.fill").foregroundColor(.white))
                    .shadow(radius: 5)
            }
            .offset(x: 45, y: 45)
            .onChange(of: selectedItem) { handleImageChange($0) }
        }
        .padding(.top, 40)
        .confirmationDialog("Are you sure you want to change your profile picture?", isPresented: $showConfirmationDialog) {
            Button("Yes") {
                if let newPic = pendingProfilePicture {
                    viewModel.profilePicture = newPic
                    viewModel.updateProfilePicture()
                }
            }
            Button("Cancel", role: .cancel) {
                pendingProfilePicture = nil
            }
        }
    }

    private var editInfoButton: some View {
        Button {
            isEditingInfo.toggle()
            isEditingInfo ? createBackup() : restoreBackup()
        } label: {
            HStack {
                Image(systemName: isEditingInfo ? "xmark.circle.fill" : "pencil.circle.fill")
                Text(isEditingInfo ? "Exit" : "Edit Profile")
            }
            .font(AppStyle.Fonts.vollkornBold(18))
            .foregroundColor(isEditingInfo ? .gray : AppStyle.Colors.accent)
            .padding()
            .background(.white.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }

    private var profileInfoFields: some View {
        Group {
            EditableFieldView(label: "Username", value: $viewModel.username, isEditable: isEditingInfo)
            EditableFieldView(label: "Email", value: $viewModel.email, isEditable: isEditingInfo)
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

    private var errorTextSection: some View {
        Group {
            if let error = errorMessage {
                Text(error)
                    .font(AppStyle.Fonts.vollkornMedium(14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private var saveProfileButton: some View {
        Button {
            let trimmed = viewModel.username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                errorMessage = "Username cannot be empty."
                return
            }
            guard trimmed.count >= 5 else {
                errorMessage = "Username must be at least 5 characters."
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.saveProfileInfo()
            }
            isEditingInfo = false
        } label: {
            Text("Save Profile")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }

    private var userPostsSection: some View {
        Group {
            if !viewModel.userPosts.isEmpty {
                Text("Your Posts")
                    .font(AppStyle.Fonts.vollkornBold(24))
                    .foregroundColor(AppStyle.Colors.base)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .horizontal])

                VStack(spacing: 16) {
                    ForEach(viewModel.userPosts, id: \.id) { post in
                        ZStack(alignment: .top) {
                            PostView(post: post)
                                .frame(width: 400, height: 480)
                                .background(AppStyle.Colors.secondary)
                                .cornerRadius(15)
                                .shadow(radius: 5)

                            HStack {
                                postEditButton(for: post)
                                Spacer()
                                postDeleteButton(for: post)
                            }
                            .padding(8)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("No posts yet.")
                    .font(AppStyle.Fonts.vollkornMedium(16))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    private func postEditButton(for post: Post) -> some View {
        Button {
            selectedPost = post
            showEditPostView = true
        } label: {
            Image(systemName: "pencil.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(AppStyle.Colors.accent)
                .padding(8)
                .background(.white.opacity(0.8))
                .clipShape(Circle())
        }
    }

    private func postDeleteButton(for post: Post) -> some View {
        Button {
            postToDelete = post
        } label: {
            Image(systemName: "trash.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.red)
                .padding(8)
                .background(.white.opacity(0.8))
                .clipShape(Circle())
        }
    }

    private var navigationLinksSection: some View {
        NavigationLink(destination: RequestedBookingsView()) {
            Text(roleManager.userRole == "admin" ? "Requested Bookings" : "Approved Requests")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }

    private var logoutButton: some View {
        Button {
            TokenManager.shared.deleteTokens()
            navigateToAuth = true
        } label: {
            Text("Log Out")
                .font(AppStyle.Fonts.vollkornBold(18))
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

    // MARK: - Helpers

    private func deletePost(_ post: Post) {
        viewModel.deletePost(postId: post.id)
    }

    private func handleImageChange(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                pendingProfilePicture = uiImage
                showConfirmationDialog = true
            }
        }
    }

    private func createBackup() {
        backupProfile = ProfileBackup(
            username: viewModel.username,
            email: viewModel.email,
            description: viewModel.description
        )
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
                .font(AppStyle.Fonts.vollkornMedium(15))
                .foregroundColor(.white)

            if isEditable {
                TextField("", text: $value)
                    .font(AppStyle.Fonts.vollkornRegular(16))
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
            } else {
                Text(value)
                    .font(AppStyle.Fonts.vollkornRegular(16))
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
                .font(AppStyle.Fonts.vollkornMedium(15))
                .foregroundColor(.white)

            if isEditable {
                TextEditor(text: $description)
                    .font(AppStyle.Fonts.vollkornRegular(16))
                    .frame(minHeight: 120, alignment: .top)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .scrollContentBackground(.hidden)
            } else {
                Text(description.isEmpty ? "Add description" : description)
                    .font(AppStyle.Fonts.vollkornRegular(16))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(minHeight: 120, alignment: .top)
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
