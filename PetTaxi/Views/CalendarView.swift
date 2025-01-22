import SwiftUI

struct CalendarView: View {
    @Binding var selectedDates: Set<Date>

    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @State private var currentMonth = Date.now

    var body: some View {
        VStack {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Text(day.formatted(.dateTime.day()))
                        .fontWeight(selectedDates.contains(day) ? .bold : .regular)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedDates.contains(day) ? Color.yellow.opacity(0.7) : Color.clear)
                        .cornerRadius(5)
                        .onTapGesture {
                            toggleDateSelection(day)
                        }
                }
            }
        }
        .onAppear {
            generateDays()
        }
        .onChange(of: currentMonth) { _ in
            generateDays()
        }
    }

    private func changeMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func generateDays() {
        days = currentMonth.calendarDisplayDays
    }

    private func toggleDateSelection(_ date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }
}
