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
                gradient: Gradient(colors: [AppStyle.Colors.accent.opacity(0.4), AppStyle.Colors.secondary.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                titleSection
                calendarSection
                if let error = errorMessage { errorText(error) }
                navigationControls
            }
        }
        .onAppear {
            loadAllDates()
        }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("Unavailable Dates")
                .font(AppStyle.Fonts.vollkornBold(24))
                .foregroundColor(AppStyle.Colors.base)
                .padding(.top, 20)

            Text("Set unavailable dates for \(viewModel.services[currentServiceIndex].serviceType.capitalized)")
                .font(AppStyle.Fonts.vollkornMedium(16))
                .foregroundColor(AppStyle.Colors.base)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var calendarSection: some View {
        CalendarView(
            selectedDates: Binding(
                get: { selectedDates[currentServiceIndex] ?? [] },
                set: { selectedDates[currentServiceIndex] = $0 }
            ),
            unavailableDates: loadUnavailableDatesForCurrentService(),
            serviceType: viewModel.services[currentServiceIndex].serviceType
        )
        .padding()
    }

    private var navigationControls: some View {
        HStack {
            if currentServiceIndex > 0 {
                Button("Back") {
                    currentServiceIndex -= 1
                }
                .font(AppStyle.Fonts.vollkornBold(16))
                .padding()
                .background(AppStyle.Colors.secondary.opacity(0.3))
                .foregroundColor(AppStyle.Colors.base)
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
            .font(AppStyle.Fonts.vollkornBold(16))
            .padding()
            .background(AppStyle.Colors.accent)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding()
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(AppStyle.Fonts.vollkornMedium(14))
            .foregroundColor(.red)
            .padding(.horizontal)
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
        for (index, dates) in selectedDates {
            viewModel.services[index].unavailableDates = dates.map { formatter.string(from: $0) }
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
