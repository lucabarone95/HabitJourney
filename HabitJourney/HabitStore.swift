import Foundation
import SwiftUI

/// Stores the weekly habits and tracks daily progress for each of them.
class HabitStore: ObservableObject {
    /// The habits active for the current week. Only three are allowed.
    @Published private(set) var habits: [Habit] = []
    /// Mapping from day -> habit id -> progress count.
    @Published private var progress: [Date: [UUID: Int]] = [:]

    // MARK: Habit management

    /// Adds a new habit if the weekly limit of three has not been reached.
    func addHabit(title: String, target: Int) {
        guard habits.count < 3 else { return }
        let habit = Habit(title: title, target: target)
        habits.append(habit)
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
}
