struct CreatePostRequest: Codable {
    let description: String
    let services: [CreateServiceRequest]
    let animalType: String
    let animalSizes: [String]
}
