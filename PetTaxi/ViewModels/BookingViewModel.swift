import Foundation

final class BookingViewModel: ObservableObject {
    @Published var selectedServiceIds: [Int] = [] // List of selected service IDs
    @Published var selectedAnimalSize: String? // Selected animal size
    @Published var bookingDates: [Int: Set<Date>] = [:] // ServiceID -> Selected Dates
    @Published var notes: String = ""
    @Published var errorMessage: String?
    @Published var isSubmitting = false
    
    @Published var isBookingActive: Bool = false
    @Published var isDateSelectionActive: Bool = false
    @Published var isNotedActive: Bool = false
    
    let animalType: String
    
    init(animalType: String) {
        self.animalType = animalType
    }

    private let communicationManager = CommunicationManager.shared

    func createBooking(serviceId: Int, completion: @escaping (Bool) -> Void) {
        // Ensure there are dates for the selected service
        guard let dates = bookingDates[serviceId]?.map({ $0.toISO8601String() }), !dates.isEmpty else {
            errorMessage = "Please select at least one date for the service."
            completion(false)
            return
        }

        // Prepare booking request
        let request = CreateBookingRequest(
            serviceId: serviceId,
            animalType: animalType.lowercased(),
            animalSize: selectedAnimalSize?.lowercased() ?? "unknown",
            bookingDates: dates,
            notes: notes
        )

        isSubmitting = true
        communicationManager.execute(
            endpoint: .createBooking,
            body: request,
            responseType: Booking.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}

extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
