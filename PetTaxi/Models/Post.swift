import Foundation
import SwiftUI

struct Post: Identifiable, Codable {
    let id: Int
    var imagesUrl: [String]?
    var description: String
    var animalType: String
    var animalSizes: [String]
    let user: User?
    var services: [Service]
    var reviews: [Review]?
}

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
    var price: Double
    var unavailableDates: [String?]
    let post: Post?
}

struct CreateServiceRequest: Codable {
    let serviceType: String
    var price: Double
    var unavailableDates: [String]?
}

struct DeletePostResponse: Codable {
    let message: String
}
