struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let access_token: String?
    let refresh_token: String?
    let user: User?
}
