struct CreateBookingRequest: Codable {
    let serviceId: Int
    let animalType: String
    let animalSize: String
    let bookingDates: [String]
    let notes: String
}
