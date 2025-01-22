//
//  User.swift
//  PetTaxi
//
//  Created by Andrey on 1.01.25.
//


struct User: Codable {
    let id: Int?
    let access_token: String?
    let email: String
    let username: String
    let role: String
    let description: String?
    let profilePic: String?
    let isEmailVerified: Bool?
}
