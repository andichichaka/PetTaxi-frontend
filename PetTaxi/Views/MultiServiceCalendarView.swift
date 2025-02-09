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
                gradient: Gradient(colors: [Color.color3.opacity(0.4), Color.color2.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Select Dates for \(services[currentServiceIndex].serviceType.capitalized)")
                    .font(.custom("Vollkorn-Bold", size: 24))
                    .foregroundColor(.color)
                    .padding(.top, 20)
                    .padding(.horizontal)

                CalendarView(
                    selectedDates: Binding(
                        get: { viewModel.bookingDates[services[currentServiceIndex].id!] ?? [] },
                        set: { viewModel.bookingDates[services[currentServiceIndex].id!] = $0 }
                    ),
                    unavailableDates: unavailableDates,
                    serviceType: services[currentServiceIndex].serviceType
                )
                .padding()

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

                    if currentServiceIndex < services.count - 1 {
                        Button("Next") {
                            currentServiceIndex += 1
                        }
                        .font(.custom("Vollkorn-Bold", size: 16))
                        .padding()
                        .background(Color.color3)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    } else {
                        Button(action: {
                            viewModel.isNotedActive = true
                        }) {
                            Text("Next")
                                .font(.custom("Vollkorn-Bold", size: 16))
                                .padding()
                                .background(Color.color3)
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
