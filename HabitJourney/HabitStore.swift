import Foundation
import SwiftUI

/// Stores the weekly habits and tracks daily progress for each of them.
class HabitStore: ObservableObject {
    /// Habits are organized by week. Each week can have at most three habits.
    @Published private var weeklyHabits: [Date: [Habit]] = [:]
    /// Mapping from day -> habit id -> progress count.
    @Published private var progress: [Date: [UUID: Int]] = [:]

    // MARK: Habit management

    /// Returns the habits for the week that contains the given date.
    func habits(for date: Date) -> [Habit] {
        let week = startOfWeek(for: date)
        return weeklyHabits[week] ?? []
    }

    /// Adds a new habit for the week of the supplied date if the limit of
    /// three has not been reached.
    func addHabit(title: String, target: Int, for date: Date) {
        let week = startOfWeek(for: date)
        guard weeklyHabits[week, default: []].count < 3 else { return }
        let habit = Habit(title: title, target: target)
        weeklyHabits[week, default: []].append(habit)
    }

    // MARK: Progress helpers

    /// Returns the progress for the given habit on a specific day.
    func progress(for habit: Habit, on date: Date) -> Int {
        let day = Calendar.current.startOfDay(for: date)
        return progress[day]?[habit.id] ?? 0
    }

    /// Sets the progress for a habit on the provided date.
    func setProgress(_ value: Int, for habit: Habit, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        progress[day, default: [:]][habit.id] = value
    }

    /// Convenience method to increase progress by one.
    func increment(_ habit: Habit, on date: Date) {
        let current = progress(for: habit, on: date)
        setProgress(current + 1, for: habit, on: date)
    }

    /// Status describing completion for a given day.
    enum Status {
        case completed, inProgress, missed
    }

    /// Returns the completion status for a habit on a date based on progress.
    func status(for habit: Habit, on date: Date) -> Status {
        let count = progress(for: habit, on: date)
        if count >= habit.target { return .completed }

        let today = Calendar.current.startOfDay(for: Date())
        let day = Calendar.current.startOfDay(for: date)
        if day < today { return .missed }
        return .inProgress
    }

    /// Calculates the first day of the week that contains the provided date.
    private func startOfWeek(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
}
