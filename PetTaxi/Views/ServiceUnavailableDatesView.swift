import SwiftUI

struct ServiceUnavailableDatesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var selectedDates: Set<Date> = []
    @State private var currentServiceIndex: Int = 0
    @State private var errorMessage: String?
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.4), Color.color2.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Unavailable Dates")
                    .font(.custom("Vollkorn-Bold", size: 24))
                    .foregroundColor(.color)
                    .padding(.top, 20)

                Text("Set unavailable dates for \(viewModel.services[currentServiceIndex].serviceType.capitalized)")
                    .font(.custom("Vollkorn-Medium", size: 16))
                    .foregroundColor(.color)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                CalendarView(
                    selectedDates: $selectedDates,
                    unavailableDates: loadUnavailableDatesForCurrentService(),
                    serviceType: viewModel.services[currentServiceIndex].serviceType
                )
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.custom("Vollkorn-Medium", size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                HStack {
                    if currentServiceIndex > 0 {
                        Button("Back") {
                            saveDatesForCurrentService()
                            currentServiceIndex -= 1
                            loadDatesForCurrentService()
                        }
                        .font(.custom("Vollkorn-Bold", size: 16))
                        .padding()
                        .background(Color.color2.opacity(0.3))
                        .foregroundColor(.color)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }

                    Spacer()

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
                    .font(.custom("Vollkorn-Bold", size: 16))
                    .padding()
                    .background(Color.color3)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                .padding()
            }
        }
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

    private func loadUnavailableDatesForCurrentService() -> [Date] {
        let formatter = ISO8601DateFormatter()
        if let unavailableDates = viewModel.services[currentServiceIndex].unavailableDates {
            return unavailableDates.compactMap { formatter.date(from: $0) }
        }
        return []
    }

    private func submitPost() {
        viewModel.createPost { success in
            if success {
                viewModel.navigateToUnavailableDates = false
                viewModel.navigateToSetPrices = false
                isActive = false
                print("Post created successfully.")
            } else {
                errorMessage = viewModel.errorMessage
            }
        }
    }
}
