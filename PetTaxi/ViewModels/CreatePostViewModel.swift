import SwiftUI

final class CreatePostViewModel: ObservableObject {
    @Published var description = ""
    @Published var services: [CreateServiceRequest] = []
    @Published var animalType = "Dog"
    @Published var animalSizes: [String] = []
    @Published var selectedImages: [UIImage]? = nil
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var unavailableDates: [[Date]] = []
    @Published var prices: [Double] = []
    @Published var selectedLocationId: Int? = nil
    @Published var locations: [Location] = []

    @Published var navigateToSetPrices = false
    @Published var navigateToUnavailableDates = false
    @Published var navigateToSubmit = false

    private let communicationManager = CommunicationManager.shared

    func createPost(completion: @escaping (Bool) -> Void) {
        guard !description.isEmpty else {
            errorMessage = "Description is required."
            completion(false)
            return
        }
        guard !services.isEmpty else {
            errorMessage = "Add at least one service."
            completion(false)
            return
        }
        guard !animalSizes.isEmpty else {
            errorMessage = "Select at least one animal size."
            completion(false)
            return
        }
        
        guard let locationId = selectedLocationId else {
                    errorMessage = "Please select a location."
                    completion(false)
                    return
                }

        let requestBody = CreatePostRequest(
            description: description,
            location: locationId,
            services: services, animalType: animalType,
            animalSizes: animalSizes
        )

        isSubmitting = true
        communicationManager.execute(
            endpoint: .createPost,
            body: requestBody,
            responseType: Post.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdPost):
                    if let images = self?.selectedImages, !images.isEmpty {
                        self?.uploadImages(postId: createdPost.id, images: images) { success in
                            self?.isSubmitting = false
                            completion(success)
                        }
                    } else {
                        self?.isSubmitting = false
                        completion(true)
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isSubmitting = false
                    completion(false)
                }
            }
        }
    }

    private func uploadImages(postId: Int, images: [UIImage], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var uploadFailed = false

        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }

            group.enter()
            communicationManager.uploadFile(
                endpoint: .custom("posts/add-images/\(postId)"),
                fileData: imageData,
                fieldName: "images",
                fileName: "image\(index).jpg",
                mimeType: "image/jpeg"
            ) { result in
                if case .failure = result {
                    uploadFailed = true
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if uploadFailed {
                self.errorMessage = "Failed to upload one or more images."
            }
            completion(!uploadFailed)
        }
    }
    
    func fetchLocations() {
        CommunicationManager.shared.execute(endpoint: .getAllLocations, responseType: [Location].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.locations = data
                    print("\(self.locations)")
                case .failure(let error):
                    print("Failed to fetch locations: \(error)")
                }
            }
        }
    }
}
