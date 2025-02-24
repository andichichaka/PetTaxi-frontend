import Foundation

class RequestedBookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    private let roleManager = RoleManager()

    func fetchBookings() {
        isLoading = true
        let endpoint: Endpoint = roleManager.userRole == "admin" ? .fetchPendingRequests : .fetchApprovedRequests
        
        CommunicationManager.shared.execute(
            endpoint: endpoint,
            responseType: [Booking].self
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let bookings):
                    self.bookings = bookings
                case .failure(let error):
                    print("Error fetching bookings: \(error.localizedDescription)")
                }
            }
        }
    }

    func approveBooking(_ bookingId: Int) {
        CommunicationManager.shared.execute(
            endpoint: .approveRequest(bookingId),
            responseType: Booking.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.bookings.removeAll { $0.id == bookingId }
                case .failure(let error):
                    print("Error approving booking: \(error.localizedDescription)")
                }
            }
        }
    }

    func disapproveBooking(_ bookingId: Int) {
        CommunicationManager.shared.execute(
            endpoint: .disaproveRequest(bookingId),
            responseType: MessageResponse.self
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.bookings.removeAll { $0.id == bookingId }
                case .failure(let error):
                    print("Error disapproving booking: \(error.localizedDescription)")
                }
            }
        }
    }
}
