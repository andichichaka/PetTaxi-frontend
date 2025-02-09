struct Profile: Codable {
    let username: String
    let email: String
    let description: String?
    let profilePicture: String?
    let posts: [Post]?
}
