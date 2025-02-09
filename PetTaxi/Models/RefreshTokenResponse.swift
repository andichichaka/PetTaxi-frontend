struct RefreshTokenResponse: Codable {
    let access_token: String
}

struct VerifyTokenResponse: Codable {
    let valid: Bool
}
