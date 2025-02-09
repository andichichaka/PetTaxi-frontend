import Foundation

struct SignUp: Codable {
    let username: String
    let email: String
    let password: String
}

struct SignUpResponse: Codable {
    let success: Bool
    let message: String?
    let user: User?
}

struct VerifyEmail: Codable {
    let userId: Int
    let code: String
}

struct VerifyEmailResponse: Codable {
    let success: Bool
    let access_token: String?
    let refresh_token: String?
    let message: String?
}

