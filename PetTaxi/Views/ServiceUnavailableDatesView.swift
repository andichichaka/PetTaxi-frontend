import SwiftUI

struct ServiceUnavailableDatesView: View {
    @ObservedObject var viewModel: CreatePostViewModel
    @State private var selectedDates: [Int: Set<Date>] = [:]
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
                    selectedDates: Binding(
                        get: { selectedDates[currentServiceIndex] ?? [] },
                        set: { selectedDates[currentServiceIndex] = $0 }
                    ),
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
                            currentServiceIndex -= 1
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
                        if currentServiceIndex < viewModel.services.count - 1 {
                            currentServiceIndex += 1
                        } else {
                            submitPost()
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
            loadAllDates()
        }
    }

    // MARK: - Helper Methods

    private func loadAllDates() {
        let formatter = ISO8601DateFormatter()
        for (index, service) in viewModel.services.enumerated() {
            selectedDates[index] = Set(service.unavailableDates?.compactMap { formatter.date(from: $0) } ?? [])
        }
    }

    private func loadUnavailableDatesForCurrentService() -> [Date] {
        let formatter = ISO8601DateFormatter()
        return viewModel.services[currentServiceIndex].unavailableDates?.compactMap { formatter.date(from: $0) } ?? []
    }

    private func submitPost() {
        let formatter = ISO8601DateFormatter()

        // Save all unavailable dates for each service on submit
        for (index, dates) in selectedDates {
            let formattedDates = dates.map { formatter.string(from: $0) }
            viewModel.services[index].unavailableDates = formattedDates
        }

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
