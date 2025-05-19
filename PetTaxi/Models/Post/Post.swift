struct Post: Identifiable, Codable {
    let id: Int
    var imagesUrl: [String]?
    var description: String
    var animalType: String
    var animalSizes: [String]
    let user: User?
    var location: Location?
    var services: [Service]
    var reviews: [Review]?
}
