//
//  Post.swift
//  PetTaxi
//
//  Created by Andrey on 26.12.24.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    let imagesUrl: [String]?
    let description: String
    let animalType: String
    let animalSizes: [String]
    let user: User
    let services: [Service]
}

//struct CreatePostRequest: Codable {
//    let description: String
//    let serviceTypes: [String]
//    let animalType: String
//    let animalSizes: [String]
//}

struct CreatePostRequest: Codable {
    let description: String
    let services: [CreateServiceRequest]
    let animalType: String
    let animalSizes: [String]
}

struct Service: Codable {
    let id: Int?
    let bookings: [Booking]?
    let serviceType: String
    let price: Double
    let unavailableDates: [String?]
}

struct Booking: Codable {
    let id: Int
    let serviceId: Int
    let userId: Int
    let bookingDate: String
    let notes: String?
}

struct CreateServiceRequest: Codable {
    let serviceType: String
    var price: Double
    var unavailableDates: [String]?
}

