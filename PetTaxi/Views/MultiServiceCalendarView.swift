//
//  MultiServiceCalendarView.swift
//  PetTaxi
//
//  Created by Andrey on 23.01.25.
//

import SwiftUI

struct MultiServiceCalendarView: View {
    @ObservedObject var viewModel: BookingViewModel
    let services: [Service]
    let unavailableDates: [Date]
    @State private var currentServiceIndex = 0

    var body: some View {
        VStack {
            Text("Select Dates for \(services[currentServiceIndex].serviceType.capitalized)")
                .font(.headline)
                .padding()

            CalendarView(
                selectedDates: Binding(
                    get: { viewModel.bookingDates[services[currentServiceIndex].id!] ?? [] },
                    set: { viewModel.bookingDates[services[currentServiceIndex].id!] = $0 }
                ),
                unavailableDates: unavailableDates
            )
            .padding()

            HStack {
                if currentServiceIndex > 0 {
                    Button("Back") {
                        currentServiceIndex -= 1
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }

                Spacer()

                if currentServiceIndex < services.count - 1 {
                    Button("Next") {
                        currentServiceIndex += 1
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                } else {
                    NavigationLink(destination: AddNotesView(viewModel: viewModel)) {
                        Text("Next")
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Select Dates")
    }
}
