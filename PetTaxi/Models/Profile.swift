//
//  Profile.swift
//  PetTaxi
//
//  Created by Andrey on 2.01.25.
//

struct Profile: Codable {
    let username: String
    let email: String
    let description: String?
    let profilePicture: String? // URL for the profile picture
}
