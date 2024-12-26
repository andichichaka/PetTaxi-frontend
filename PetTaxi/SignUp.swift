//
//  Profile.swift
//  Jigit
//
//  Created by Andrey on 10.07.24.
//

import Foundation

struct SignUp: Codable {
    let username: String
    let email: String
    let password: String
}

struct SignUpResponse: Codable {
    let success: Bool
    let access_token: String?
    let message: String?
    let user: User?
}
