//
//  LogIn.swift
//  Jigit
//
//  Created by Andrey on 12.07.24.
//

import Foundation

struct LogIn: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String?
    let access_token: String?
    let user: User?
}
