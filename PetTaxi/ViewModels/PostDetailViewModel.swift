import Foundation

final class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var reviews: [Review] = []
    @Published var newReviewText: String = ""
    @Published var errorMessage: String?

    private let communicationManager = CommunicationManager.shared

    init(post: Post) {
        self.post = post
        fetchReviews()
    }

    func fetchReviews() {
        communicationManager.execute(
            endpoint: .getReviews(post.id),
            responseType: [Review].self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reviews):
                    self.reviews = reviews
                case .failure(let error):
                    self.errorMessage = "Failed to fetch reviews: \(error.localizedDescription)"
                }
            }
        }
    }

    func submitReview() {
        guard !newReviewText.isEmpty else {
            errorMessage = "Review cannot be empty"
            return
        }

        let newReview = ["comment": newReviewText]

        communicationManager.execute(
            endpoint: .createReview(post.id),
            body: newReview,
            responseType: Review.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let review):
                    self.reviews.insert(review, at: 0)
                    self.newReviewText = ""
                case .failure(let error):
                    self.errorMessage = "Failed to submit review: \(error.localizedDescription)"
                }
            }
        }
    }
}
