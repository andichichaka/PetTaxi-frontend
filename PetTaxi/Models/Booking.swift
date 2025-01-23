//
//  Booking.swift
//  PetTaxi
//
//  Created by Andrey on 23.01.25.
//

import Foundation

struct CreateBookingRequest: Codable {
    let serviceId: Int
    let animalType: String
    let animalSize: String
    let bookingDates: [String]
    let notes: String
}

//struct Booking: Codable {
//    let id: Int
//    let services: [Service]
//    let user: User
//    let animalType: String
//    let animalSize: String
//    let bookingDates: [String]
//    let price: Double
//    let notes: String
//    let isApproved: Bool
//    let createdAt: String
//}
