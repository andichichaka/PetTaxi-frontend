import Foundation
import UIKit

final class HomePageViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: String?
    private let communicationManager = CommunicationManager.shared

    func fetchPosts() {
        communicationManager.execute(
            endpoint: .fetchPosts,
            responseType: [Post].self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    self.posts = fetchedPosts
                case .failure(let error):
                    if case CommunicationError.unauthorized = error {
                        TokenManager.shared.deleteToken()
                        self.errorMessage = "Unauthorized. Please log in again."
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func uploadProfilePicture(image: UIImage, completion: @escaping (Bool) -> Void) {
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                print("Failed to convert UIImage to data")
//                completion(false)
//                return
//            }
//
//            let boundary = UUID().uuidString
//            let url = Endpoint.uploadProfilePicture.url
//
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//            request.setValue("Bearer \(TokenManager.shared.getToken() ?? "")", forHTTPHeaderField: "Authorization")
//
//            var body = Data()
//            body.append("--\(boundary)\r\n")
//            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n")
//            body.append("Content-Type: image/jpeg\r\n\r\n")
//            body.append(imageData)
//            body.append("\r\n--\(boundary)--\r\n")
//
//            request.httpBody = body
//
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    print("Upload failed: \(error.localizedDescription)")
//                    completion(false)
//                    return
//                }
//
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    print("Upload failed with invalid response")
//                    completion(false)
//                    return
//                }
//
//                completion(true)
//            }.resume()
        }
}
