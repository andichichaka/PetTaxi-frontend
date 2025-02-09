import SwiftUI

final class SearchFilterViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var serviceTypes: [String] = []
    @Published var animalType: String = ""
    @Published var animalSizes: [String] = []
    @Published var filteredPosts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let communicationManager = CommunicationManager.shared

    func performSearch(completion: @escaping (Bool) -> Void) {
        var queryItems = [URLQueryItem]()
        if !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "keywords", value: keyword.lowercased()))
        }
        serviceTypes.forEach {
            queryItems.append(URLQueryItem(name: "serviceTypes", value: $0.lowercased()))
        }
        if !animalType.isEmpty {
            queryItems.append(URLQueryItem(name: "animalType", value: animalType.lowercased()))
        }
        animalSizes.forEach {
            queryItems.append(URLQueryItem(name: "animalSizes", value: $0.lowercased()))
        }
        let endpoint = Endpoint.customWithQuery("posts/search", queryItems)

        isLoading = true
        communicationManager.execute(endpoint: endpoint, body: nil, responseType: [Post].self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let posts):
                    self?.filteredPosts = posts
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    func clearFilters() {
            keyword = ""
            serviceTypes = []
            animalType = ""
            animalSizes = []
        }
}
