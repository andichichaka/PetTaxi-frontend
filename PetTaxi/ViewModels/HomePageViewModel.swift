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
                        TokenManager.shared.deleteTokens()
                        self.errorMessage = "Unauthorized. Please log in again."
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
