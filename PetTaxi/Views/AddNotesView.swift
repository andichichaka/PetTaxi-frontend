import SwiftUI

struct AddNotesView: View {
    @ObservedObject var viewModel: BookingViewModel
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Add Notes")
                .font(.largeTitle)
                .bold()

            // Text Editor for Notes
            VStack(alignment: .leading) {
                Text("Notes for the service provider")
                    .font(.headline)
                    .foregroundColor(.gray)
                TextEditor(text: $viewModel.notes)
                    .frame(height: 150)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            .padding(.horizontal)

            // Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Spacer()

            // Submit Booking Button
            Button(action: submitBooking) {
                if isSubmitting {
                    ProgressView()
                        .padding()
                } else {
                    Text("Submit Booking")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            }
            .disabled(isSubmitting)
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle("Add Notes")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }

    private func submitBooking() {
        // Ensure at least one service is selected
        guard !viewModel.selectedServiceIds.isEmpty else {
            viewModel.errorMessage = "Please select at least one service."
            return
        }

        // Start submitting
        isSubmitting = true
        viewModel.errorMessage = nil // Clear previous errors
        let group = DispatchGroup()
        var hasError = false

        // Submit bookings for each selected service
        for serviceId in viewModel.selectedServiceIds {
            group.enter()
            viewModel.createBooking(serviceId: serviceId) { success in
                if !success {
                    hasError = true
                }
                group.leave()
            }
        }

        // Notify when all requests are complete
        group.notify(queue: .main) {
            isSubmitting = false
            if hasError {
                viewModel.errorMessage = "Failed to create one or more bookings."
            } else {
                print("All bookings submitted successfully.")
            }
        }
    }
}
