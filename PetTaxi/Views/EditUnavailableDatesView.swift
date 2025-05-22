import SwiftUI

struct EditUnavailableDatesView: View {
    @Binding var service: Service
    @Binding var isPresented: Bool
    @State private var selectedDates: Set<Date> = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerTitle
                subTitle
                calendar
                if let errorMessage {
                    errorText(errorMessage)
                }
                saveButton
            }
            .padding()
            .onAppear(perform: loadSelectedDates)
            .navigationTitle("Edit Dates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(AppStyle.Fonts.vollkornMedium(16))
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerTitle: some View {
        Text("Edit Unavailable Dates")
            .font(AppStyle.Fonts.vollkornBold(24))
            .foregroundColor(AppStyle.Colors.base)
    }

    private var subTitle: some View {
        Text("Select unavailable dates for \(service.serviceType.capitalized)")
            .font(AppStyle.Fonts.vollkornMedium(16))
            .foregroundColor(AppStyle.Colors.base)
            .multilineTextAlignment(.center)
    }

    private var calendar: some View {
        CalendarView(
            selectedDates: $selectedDates,
            unavailableDates: loadUnavailableDates(),
            serviceType: service.serviceType
        )
        .padding(.vertical, 5)
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .font(AppStyle.Fonts.vollkornMedium(13))
            .padding(.top, 5)
    }

    private var saveButton: some View {
        Button(action: saveDates) {
            Text("Done")
                .font(AppStyle.Fonts.vollkornBold(18))
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppStyle.Colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }

    // MARK: - Logic

    private func saveDates() {
        guard !selectedDates.isEmpty else {
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
