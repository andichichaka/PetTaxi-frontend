struct VerifyEmailResponse: Codable {
    let success: Bool
    let access_token: String?
    let refresh_token: String?
    let message: String?
}
