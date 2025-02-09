import SwiftUI

struct CalendarView: View {
    @Binding var selectedDates: Set<Date>
    let unavailableDates: [Date]
    let serviceType: String
    @State private var errorMessage: String?

    let daysOfWeek = Calendar.current.shortWeekdaySymbols.shiftedToMonday()
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

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top)
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
        if serviceType == "weekly walking" || serviceType == "weekly sitting" {
            toggleEntireWeekSelection(for: date)
        } else {
            if selectedDates.contains(date) {
                selectedDates.remove(date)
            } else {
                selectedDates.insert(date)
            }
        }
    }

    private func toggleEntireWeekSelection(for date: Date) {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return }
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        
        let availableDays = weekDays.filter { !unavailableDates.contains($0) && $0 >= Calendar.current.startOfDay(for: Date()) }

        if availableDays.count < 5 {
            errorMessage = "At least five days of the week must be available."
            return
        }
        
        if availableDays.allSatisfy({ selectedDates.contains($0) }) {
            availableDays.forEach { selectedDates.remove($0) }
        } else {
            selectedDates.formUnion(availableDays)
        }
        
        errorMessage = nil
    }
}

// MARK: - Extensions

extension Array where Element == String {
    func shiftedToMonday() -> [String] {
        var shifted = self
        if let sunday = shifted.first {
            shifted.removeFirst()
            shifted.append(sunday)
        }
        return shifted
    }
}

extension Date {
    func generateCalendarDays() -> [Date] {
        let calendar = Calendar.current
        guard let monthRange = calendar.range(of: .day, in: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [Date] = []
        
        if let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth),
           let previousMonthRange = calendar.range(of: .day, in: .month, for: startOfPreviousMonth) {
            let leadingDaysCount = (firstWeekday - 2 + 7) % 7 // Adjust for Monday start
            let previousMonthDays = Array(previousMonthRange.suffix(leadingDaysCount))
            previousMonthDays.forEach { day in
                if let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.startOfDay(for: startOfPreviousMonth)) {
                    days.append(date)
                }
            }
        }
        
        monthRange.forEach { day in
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
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
