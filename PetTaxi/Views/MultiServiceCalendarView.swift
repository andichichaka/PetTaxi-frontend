import SwiftUI

struct MultiServiceCalendarView: View {
    @ObservedObject var viewModel: BookingViewModel
    let services: [Service]
    let unavailableDates: [Date]
    @State private var currentServiceIndex = 0
    @State private var isAddNotesViewActive: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    AppStyle.Colors.accent.opacity(0.4),
                    AppStyle.Colors.secondary.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                headerText
                calendar
                navigationButtons
            }
        }
        .navigationDestination(isPresented: $viewModel.isNotedActive) {
            AddNotesView(viewModel: viewModel)
        }
    }

    // MARK: - Subviews

    private var headerText: some View {
        Text("Select Dates for \(services[currentServiceIndex].serviceType.capitalized)")
            .font(AppStyle.Fonts.vollkornBold(24))
            .foregroundColor(AppStyle.Colors.base)
            .padding(.top, 20)
            .padding(.horizontal)
    }

    private var calendar: some View {
        CalendarView(
            selectedDates: Binding(
                get: { viewModel.bookingDates[services[currentServiceIndex].id!] ?? [] },
                set: { viewModel.bookingDates[services[currentServiceIndex].id!] = $0 }
            ),
            unavailableDates: unavailableDates,
            serviceType: services[currentServiceIndex].serviceType
        )
        .padding()
    }

    private var navigationButtons: some View {
        HStack {
            if currentServiceIndex > 0 {
                backButton
            }

            Spacer()

            if currentServiceIndex < services.count - 1 {
                nextButton
            } else {
                continueToNotesButton
            }
        }
        .padding()
    }

    private var backButton: some View {
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

    private var nextButton: some View {
        Button("Next") {
            currentServiceIndex += 1
        }
        .font(AppStyle.Fonts.vollkornBold(16))
        .padding()
        .background(AppStyle.Colors.accent)
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }

    private var continueToNotesButton: some View {
        Button {
            viewModel.isNotedActive = true
        } label: {
            Text("Next")
                .font(AppStyle.Fonts.vollkornBold(16))
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
    }
}
