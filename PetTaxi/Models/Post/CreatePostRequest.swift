struct CreatePostRequest: Codable {
    let description: String
    let location: Int
    let services: [CreateServiceRequest]
    let animalType: String
    let animalSizes: [String]
}
