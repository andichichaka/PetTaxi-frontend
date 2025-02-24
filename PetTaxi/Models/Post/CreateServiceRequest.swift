struct CreateServiceRequest: Codable {
    let serviceType: String
    var price: Double
    var unavailableDates: [String]?
}
