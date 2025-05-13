import SwiftUI

final class SearchFilterViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var serviceTypes: [String] = []
    @Published var animalType: String = ""
    @Published var animalSizes: [String] = []
    @Published var filteredPosts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedLocationId: Int?
    @Published var locations: [Location] = []

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
        if let locationId = selectedLocationId {
            queryItems.append(URLQueryItem(name: "locationId", value: String(locationId)))
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
    
    func fetchLocations() {
        CommunicationManager.shared.execute(
            endpoint: .getAllLocations,
            responseType: [Location].self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self.locations = locations
                case .failure(let error):
                    self.errorMessage = "Failed to load locations: \(error.localizedDescription)"
                }
            }
        }
    }
}
