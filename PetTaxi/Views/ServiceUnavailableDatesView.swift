import SwiftUI

struct ServiceUnavailableDatesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var selectedDates: Set<Date> = []
    @State private var currentServiceIndex: Int = 0
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Unavailable Dates")
                .font(.title)
                .bold()

            Text("Set unavailable dates for \(viewModel.services[currentServiceIndex].serviceType.capitalized)")
                .font(.headline)
                .multilineTextAlignment(.center)

            CalendarView(selectedDates: $selectedDates)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            HStack {
                Button("Back") {
                    if currentServiceIndex > 0 {
                        saveDatesForCurrentService()
                        currentServiceIndex -= 1
                        loadDatesForCurrentService()
                    }
                }
                .disabled(currentServiceIndex == 0)
                .frame(maxWidth: .infinity)
                .padding()
                .background(currentServiceIndex > 0 ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button(currentServiceIndex == viewModel.services.count - 1 ? "Submit" : "Next") {
                    if validateDates() {
                        saveDatesForCurrentService()
                        if currentServiceIndex < viewModel.services.count - 1 {
                            currentServiceIndex += 1
                            loadDatesForCurrentService()
                        } else {
                            submitPost()
                        }
                    } else {
                        errorMessage = "Please select at least one unavailable date."
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            loadDatesForCurrentService()
        }
    }

    // MARK: - Helper Methods

    private func validateDates() -> Bool {
        return !selectedDates.isEmpty
    }

    private func saveDatesForCurrentService() {
        let unavailableDates = selectedDates.map { date -> String in
            let formatter = ISO8601DateFormatter()
            return formatter.string(from: date)
        }
        viewModel.services[currentServiceIndex].unavailableDates = unavailableDates
    }


    private func loadDatesForCurrentService() {
        let formatter = ISO8601DateFormatter()
        if let dates = viewModel.services[currentServiceIndex].unavailableDates {
            selectedDates = Set(dates.compactMap { formatter.date(from: $0) })
        } else {
            selectedDates = []
        }
    }


    private func submitPost() {
        viewModel.createPost { success in
            if success {
                viewModel.navigateToUnavailableDates = false
                viewModel.navigateToSetPrices = false
                print("Post created successfully.")
            } else {
                errorMessage = viewModel.errorMessage
            }
        }
    }
}
