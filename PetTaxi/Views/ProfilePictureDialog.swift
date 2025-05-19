import SwiftUI
import PhotosUI

struct ProfilePictureDialog: View {
    @Binding var isActive: Bool
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var errorMessage: String?
    @StateObject private var viewModel = ProfileViewModel()

    let action: () -> Void
    let skipAction: () -> Void

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }

            dialogContent
                .padding()
                .background(AppStyle.Colors.light)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
                .padding(30)
        }
        .ignoresSafeArea()
    }

    // MARK: - Components

    private var dialogContent: some View {
        VStack(spacing: 20) {
            Text("Welcome! 👋")
                .font(AppStyle.Fonts.vollkornBold(25))
                .padding(.top)

            Text("Let's start by adding a profile picture to personalize your account.")
                .font(AppStyle.Fonts.vollkornMedium(18))
                .multilineTextAlignment(.center)

            profileImagePreview

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Choose Image")
                    .font(AppStyle.Fonts.vollkornMedium(16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.Colors.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) { _ in Task { await loadSelectedImage() } }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(AppStyle.Fonts.vollkornRegular(12))
                    .padding(.top)
            }

            actionButtons
        }
    }

    private var profileImagePreview: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppStyle.Colors.secondary, lineWidth: 4))
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Skip") {
                skipAction()
                close()
            }
            .font(AppStyle.Fonts.vollkornMedium(16))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            Button("Continue") {
                guard let image = selectedImage else {
                    errorMessage = "Please select an image"
                    return
                }
                isUploading = true
                viewModel.profilePicture = image
                viewModel.uploadProfilePicture()
                close()
            }
            .font(AppStyle.Fonts.vollkornBold(16))
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImage != nil ? AppStyle.Colors.accent : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(selectedImage == nil || isUploading)
        }
    }

    // MARK: - Helpers

    private func close() {
        isActive = false
    }

    private func loadSelectedImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
        } else {
            errorMessage = "Failed to load image. Please try again."
        }
    }
}

#Preview {
    ProfilePictureDialog(isActive: .constant(true), action: {}, skipAction: {})
}
