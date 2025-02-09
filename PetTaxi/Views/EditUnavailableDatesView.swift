import SwiftUI

struct EditUnavailableDatesView: View {
    @Binding var service: Service
    @Binding var isPresented: Bool
    @State private var selectedDates: Set<Date> = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit Unavailable Dates")
                    .font(.title)
                    .bold()

                Text("Select unavailable dates for \(service.serviceType.capitalized)")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                CalendarView(
                    selectedDates: $selectedDates,
                    unavailableDates: loadUnavailableDates(),
                    serviceType: service.serviceType
                )

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: saveDates) {
                    Text("Done")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .onAppear {
                loadSelectedDates()
            }
            .navigationTitle("Edit Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func saveDates() {
        if selectedDates.isEmpty {
            errorMessage = "Please select at least one unavailable date."
            return
        }

        let formatter = ISO8601DateFormatter()
        service.unavailableDates = selectedDates.map { formatter.string(from: $0) }
        isPresented = false
    }

    private func loadSelectedDates() {
        let formatter = ISO8601DateFormatter()
        selectedDates = Set(service.unavailableDates.compactMap { formatter.date(from: $0 ?? "") })
    }

    private func loadUnavailableDates() -> [Date] {
        let formatter = ISO8601DateFormatter()
        return service.unavailableDates.compactMap { formatter.date(from: $0 ?? "") }
    }
}
