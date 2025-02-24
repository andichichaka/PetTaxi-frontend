struct User: Codable {
    let id: Int?
    let access_token: String?
    let refresh_token: String?
    let email: String
    var username: String
    let role: String?
    let description: String?
    var profilePic: String?
    let isEmailVerified: Bool?
}
