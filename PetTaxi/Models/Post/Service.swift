struct Service: Codable {
    let id: Int?
    let bookings: [Booking]?
    let serviceType: String
    var price: Double
    var unavailableDates: [String?]
    let post: Post?
}
