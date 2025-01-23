import SwiftUI

struct CalendarView: View {
    @Binding var selectedDates: Set<Date>
    let unavailableDates: [Date]
    
    let daysOfWeek = Calendar.current.shortWeekdaySymbols
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @State private var currentMonth = Date.now
    
    var body: some View {
        VStack {
            // Month Navigation
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

            // Days of the Week
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    let isUnavailable = day < Calendar.current.startOfDay(for: Date()) || unavailableDates.contains(day)
                    Text(day.formatted(.dateTime.day()))
                        .fontWeight(selectedDates.contains(day) ? .bold : .regular)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(selectedDates.contains(day) ? Color.yellow.opacity(0.7) : Color.clear)
                        .foregroundColor(isUnavailable ? .gray : .primary)
                        .cornerRadius(5)
                        .onTapGesture {
                            if !isUnavailable {
                                toggleDateSelection(day)
                            }
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
    
    // MARK: - Helper Functions
    private func changeMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func generateDays() {
        days = currentMonth.generateCalendarDays()
    }
    
    private func toggleDateSelection(_ date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }
}

// MARK: - Extensions

extension Date {
    /// Generates all days in the current month, including leading/trailing days for alignment
    func generateCalendarDays() -> [Date] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        // First weekday of the month
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [Date] = []
        
        // Add leading days (previous month)
        if let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth),
           let previousMonthRange = calendar.range(of: .day, in: .month, for: startOfPreviousMonth) {
            let leadingDaysCount = firstWeekday - 1
            let previousMonthDays = Array(previousMonthRange.suffix(leadingDaysCount))
            previousMonthDays.forEach { day in
                if let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: startOfPreviousMonth)) {
                    days.append(date)
                }
            }
        }
        
        // Add current month days
        monthRange.forEach { day in
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Add trailing days (next month)
        let trailingDaysCount = 42 - days.count
        if let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth) {
            (1...trailingDaysCount).forEach { day in
                if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfNextMonth) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
}
