import SwiftUI

struct MultiServiceCalendarView: View {
    @ObservedObject var viewModel: BookingViewModel
    let services: [Service]
    let unavailableDates: [Date]
    @State private var currentServiceIndex = 0
    @State private var isAddNotesViewActive: Bool = false // Navigation to AddNotesView

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.color3.opacity(0.4), Color.color2.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                // Heading at the Top
                Text("Select Dates for \(services[currentServiceIndex].serviceType.capitalized)")
                    .font(.custom("Vollkorn-Bold", size: 24)) // Custom Font
                    .foregroundColor(.color) // Dark Green
                    .padding(.top, 20)
                    .padding(.horizontal)

                // Calendar View
                CalendarView(
                    selectedDates: Binding(
                        get: { viewModel.bookingDates[services[currentServiceIndex].id!] ?? [] },
                        set: { viewModel.bookingDates[services[currentServiceIndex].id!] = $0 }
                    ),
                    unavailableDates: unavailableDates,
                    serviceType: services[currentServiceIndex].serviceType
                )
                .padding()

                // Navigation Buttons
                HStack {
                    if currentServiceIndex > 0 {
                        Button("Back") {
                            currentServiceIndex -= 1
                        }
                        .font(.custom("Vollkorn-Bold", size: 16)) // Custom Font
                        .padding()
                        .background(Color.color2.opacity(0.3)) // Light Green
                        .foregroundColor(.color) // Dark Green
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }

                    Spacer()

                    if currentServiceIndex < services.count - 1 {
                        Button("Next") {
                            currentServiceIndex += 1
                        }
                        .font(.custom("Vollkorn-Bold", size: 16)) // Custom Font
                        .padding()
                        .background(Color.color3) // Mint Green
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    } else {
                        Button(action: {
                            viewModel.isNotedActive = true
                        }) {
                            Text("Next")
                                .font(.custom("Vollkorn-Bold", size: 16)) // Custom Font
                                .padding()
                                .background(Color.color3) // Mint Green
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $viewModel.isNotedActive) {
            AddNotesView(viewModel: viewModel)
        }
    }
}
