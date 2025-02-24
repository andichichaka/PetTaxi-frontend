struct SignUpResponse: Codable {
    let success: Bool
    let message: String?
    let user: User?
}
