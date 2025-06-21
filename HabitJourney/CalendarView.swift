import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @ObservedObject var store: HabitStore

    private var calendar: Calendar { Calendar.current }
    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) ?? selectedDate
    }
    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1...30
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        return days
    }

    var body: some View {
        VStack {
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns) {
                ForEach(Array(daysInMonth.enumerated()), id: \..offset) { _, date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 30)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let completed = completionStatus(for: date)
        Button(action: { selectedDate = date }) {
            Text(String(calendar.component(.day, from: date)))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(4)
                .background(backgroundColor(for: date, completed: completed))
                .clipShape(Circle())
                .foregroundColor(textColor(for: date))
        }
        .buttonStyle(.plain)
        .frame(height: 30)
    }

    private func completionStatus(for date: Date) -> Bool {
        let habits = store.habits(for: date)
        guard !habits.isEmpty else { return false }
        return habits.allSatisfy { store.status(for: $0, on: date) == .completed }
    }

    private func backgroundColor(for date: Date, completed: Bool) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return .accentColor
        }
        return completed ? Color.green.opacity(0.3) : Color.clear
    }

    private func textColor(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return .white
        }
        return .primary
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()), store: HabitStore())
}
