import SwiftUI

struct AddNotesView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.4), Color.color2.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Add Notes")
                    .font(.custom("Vollkorn-Bold", size: 28))
                    .foregroundColor(.color)
                    .padding(.top, 20)

                VStack(alignment: .leading) {
                    Text("Notes for the service provider")
                        .font(.custom("Vollkorn-Medium", size: 16))
                        .foregroundColor(.gray)

                    TextEditor(text: $viewModel.notes)
                        .font(.custom("Vollkorn-Regular", size: 16))
                        .frame(height: 150)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.custom("Vollkorn-Medium", size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()

                Button(action: submitBooking) {
                    if isSubmitting {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Submit Booking")
                            .font(.custom("Vollkorn-Bold", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.color3)
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
        guard !viewModel.selectedServiceIds.isEmpty else {
            viewModel.errorMessage = "Please select at least one service."
            return
        }

        isSubmitting = true
        viewModel.errorMessage = nil
        let group = DispatchGroup()
        var hasError = false

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
            }
        }
    }
}
