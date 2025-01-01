//
//  ProfilePictureDialog.swift
//  PetTaxi
//
//  Created by Andrey on 29.12.24.
//

import SwiftUI
import PhotosUI

struct ProfilePictureDialog: View {
    @Binding var isActive: Bool
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var errorMessage: String?
    
    let action: () -> Void // Completion action after a successful upload
    let skipAction: () -> Void // Skip action if the user decides not to upload

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
                    .font(.title2)
                    .bold()
                    .padding()

                Text("Let's start by adding a profile picture to personalize your account.")
                    .font(.body)
                    .multilineTextAlignment(.center)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.yellow, lineWidth: 4))
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

                PhotosPicker(selection: $selectedItems, matching: .images) {
                    Text("Choose Image")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .onChange(of: selectedItems) { _ in
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
                        guard let selectedImage = selectedImage,
                              let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
                            errorMessage = "Please select an image"
                            return
                        }
                        isUploading = true
                        uploadProfilePicture(imageData: imageData)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedImage != nil ? Color.yellow : Color.gray)
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
        guard let item = selectedItems.first else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            selectedImage = uiImage
        } else {
            errorMessage = "Failed to load image. Please try again."
        }
    }

    private func uploadProfilePicture(imageData: Data) {
        let endpoint = Endpoint.custom("profile/upload-profile-pic") // Adjust this to the actual endpoint for uploading profile pictures
        communicationManager.uploadFile(
            endpoint: endpoint,
            fileData: imageData,
            fieldName: "file",
            fileName: "profile_picture.jpg",
            mimeType: "image/jpeg"
        ) { result in
            DispatchQueue.main.async {
                isUploading = false
                switch result {
                case .success:
                    action()
                    close()
                case .failure(let error):
                    errorMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
