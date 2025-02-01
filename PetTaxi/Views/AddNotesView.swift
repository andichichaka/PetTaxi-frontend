import SwiftUI

struct AddNotesView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss // Handle navigation back on success
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.4), Color.color2.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Title
                Text("Add Notes")
                    .font(.custom("Vollkorn-Bold", size: 28)) // Custom Font
                    .foregroundColor(.color) // Dark Green
                    .padding(.top, 20)

                // Text Editor for Notes
                VStack(alignment: .leading) {
                    Text("Notes for the service provider")
                        .font(.custom("Vollkorn-Medium", size: 16)) // Custom Font
                        .foregroundColor(.gray)

                    TextEditor(text: $viewModel.notes)
                        .font(.custom("Vollkorn-Regular", size: 16)) // Custom Font
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
                        .font(.custom("Vollkorn-Medium", size: 14)) // Custom Font
                        .foregroundColor(.red)
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
                            .font(.custom("Vollkorn-Bold", size: 18)) // Custom Font
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color3) // Mint Green
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                }
                .disabled(isSubmitting)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Add Notes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submitBooking() {
        // Ensure at least one service is selected
        guard !viewModel.selectedServiceIds.isEmpty else {
            viewModel.errorMessage = "Please select at least one service."
            return
        }

        // Start submitting
        isSubmitting = true
        viewModel.errorMessage = nil
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

        group.notify(queue: .main) {
            isSubmitting = false
            if hasError {
                viewModel.errorMessage = "Failed to create one or more bookings."
            } else {
                viewModel.isNotedActive = false
                viewModel.isDateSelectionActive = false
                viewModel.isBookingActive = false
                //dismiss() // Automatically return to the previous screen on success
            }
        }
    }
}
