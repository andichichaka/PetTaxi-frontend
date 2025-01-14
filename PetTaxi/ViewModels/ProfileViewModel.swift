//
//  ProfileViewModel.swift
//  PetTaxi
//
//  Created by Andrey on 2.01.25.
//

import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    @Published var username: String = "N/A"
    @Published var email: String = "N/A"
    @Published var description: String? = nil // Optional description
    @Published var profilePicture: UIImage?
    @Published var role: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let communicationManager = CommunicationManager.shared

    func fetchProfile() {
        isLoading = true
        communicationManager.execute(
            endpoint: .getProfile,
            responseType: Profile.self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.username = profile.username
                    self.email = profile.email
                    self.description = profile.description // Optional
                    if let profilePictureUrl = profile.profilePicture {
                        self.loadImage(from: profilePictureUrl)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func uploadProfilePicture() {
        guard let profilePicture = profilePicture,
              let imageData = profilePicture.jpegData(compressionQuality: 0.8) else {
            errorMessage = "No valid image to upload."
            return
        }

        isLoading = true
        communicationManager.uploadFile(
            endpoint: .uploadPic,
            fileData: imageData,
            fieldName: "file",
            fileName: "profile_picture.jpg",
            mimeType: "image/jpeg"
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("Profile picture uploaded successfully")
                case .failure(let error):
                    self.errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateProfilePicture() {
        guard let profilePicture = profilePicture,
              let imageData = profilePicture.jpegData(compressionQuality: 0.8) else {
            errorMessage = "No valid image to upload."
            return
        }

        isLoading = true
        communicationManager.uploadFile(
            endpoint: .updatePic,
            fileData: imageData,
            fieldName: "file",
            fileName: "profile_picture.jpg",
            mimeType: "image/jpeg"
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("Profile picture uploaded successfully")
                case .failure(let error):
                    self.errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func saveProfileInfo() {
            let updateProfile = UpdateProfile(
                email: email,
                username: username,
                description: description!
            )

            isLoading = true
            communicationManager.execute(
                endpoint: .updateProfile,
                body: updateProfile,
                responseType: Profile.self
            ) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success:
                        print("Profile updated successfully")
                    case .failure(let error):
                        self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                    }
                }
            }
        }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profilePicture = image
                }
            }
        }.resume()
    }
    
    func submitRole(_ role: String, completion: @escaping (Bool) -> Void) {
            let requestBody = ["role": role]

            communicationManager.execute(
                endpoint: .setRole,
                body: requestBody,
                responseType: User.self
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        print("Role submitted successfully: \(user.role)")
                        completion(true)
                    case .failure(let error):
                        print("Failed to submit role: \(error.localizedDescription)")
                        self.errorMessage = "Failed to submit role: \(error.localizedDescription)"
                        completion(false)
                    }
                }
            }
        }
}
