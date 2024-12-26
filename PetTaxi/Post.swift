//
//  Post.swift
//  PetTaxi
//
//  Created by Andrey on 26.12.24.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    let imagesUrl: String
    let description: String
    let serviceType: String
    let animalType: String
    let user: User
}
