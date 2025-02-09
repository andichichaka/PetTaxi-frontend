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

    private let communicationManager = CommunicationManager.shared

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }

            VStack(spacing: 20) {
                Text("Welcome! 👋")
                    .font(.custom("Vollkorn-Bold", size: 25))
                    .bold()
                    .padding()

                Text("Let's start by adding a profile picture to personalize your account.")
                    .font(.custom("Vollkorn-Medium", size: 18))
                    .multilineTextAlignment(.center)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.color2, lineWidth: 4))
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

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Choose Image")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.color2)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: selectedItem) { _ in
                    Task {
                        await loadSelectedImage()
                    }
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top)
                }

                HStack {
                    Button("Skip") {
                        skipAction()
                        close()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    Button("Continue") {
                        guard let selectedImage = selectedImage else {
                            errorMessage = "Please select an image"
                            return
                        }
                        isUploading = true
                        viewModel.profilePicture = selectedImage
                        viewModel.uploadProfilePicture()
                        close()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedImage != nil ? Color.color3 : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(selectedImage == nil || isUploading)
                }
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .padding(30)
        }
        .ignoresSafeArea()
    }

    private func close() {
        isActive = false
    }

    private func loadSelectedImage() async {
        guard let item = selectedItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            selectedImage = uiImage
        } else {
            errorMessage = "Failed to load image. Please try again."
        }
    }
}

#Preview{
    ProfilePictureDialog(isActive: .constant(true), action: {}, skipAction: {})
}
