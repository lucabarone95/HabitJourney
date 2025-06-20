import Foundation
import SwiftUI

/// Stores the weekly habits and tracks daily progress for each of them.
class HabitStore: ObservableObject {
    /// Habits are organized by week. Each week can have at most three habits.
    @Published private var weeklyHabits: [Date: [Habit]] = [:]
    /// Mapping from day -> sub-habit id -> progress count.
    @Published private var progress: [Date: [UUID: Int]] = [:]

    // MARK: Habit management

    /// Returns the habits for the week that contains the given date.
    func habits(for date: Date) -> [Habit] {
        let week = startOfWeek(for: date)
        return weeklyHabits[week] ?? []
    }

    /// Adds a new habit for the week of the supplied date if the limit of
    /// three has not been reached. A new habit always starts with one
    /// sub-habit.
    func addHabit(title: String,
                  category: HabitCategory,
                  subHabitTitle: String,
                  target: Int,
                  for date: Date) {
        let week = startOfWeek(for: date)
        guard weeklyHabits[week, default: []].count < 3 else { return }
        let sub = SubHabit(title: subHabitTitle, target: target)
        let habit = Habit(title: title, category: category, subHabits: [sub])
        weeklyHabits[week, default: []].append(habit)
    }

    /// Rename an existing habit in a given week.
    func renameHabit(_ habit: Habit, to newTitle: String, for date: Date) {
        updateHabit(habit, for: date) { $0.title = newTitle }
    }

    /// Add a new sub-habit to an existing habit in the given week.
    func addSubHabit(to habit: Habit, title: String, target: Int, for date: Date) {
        updateHabit(habit, for: date) { $0.subHabits.append(SubHabit(title: title, target: target)) }
    }

    /// Helper used to modify a habit inside the storage.
    private func updateHabit(_ habit: Habit, for date: Date, mutate: (inout Habit) -> Void) {
        let week = startOfWeek(for: date)
        guard var habits = weeklyHabits[week],
              let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        var copy = habits[index]
        mutate(&copy)
        habits[index] = copy
        weeklyHabits[week] = habits
    }

    // MARK: Progress helpers

    /// Returns the progress for the given sub-habit on a specific day.
    func progress(for subHabit: SubHabit, on date: Date) -> Int {
        let day = Calendar.current.startOfDay(for: date)
        return progress[day]?[subHabit.id] ?? 0
    }

    /// Sets the progress for a sub-habit on the provided date.
    func setProgress(_ value: Int, for subHabit: SubHabit, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        progress[day, default: [:]][subHabit.id] = value
    }

    /// Convenience method to increase progress by one.
    func increment(_ subHabit: SubHabit, on date: Date) {
        let current = progress(for: subHabit, on: date)
        setProgress(current + 1, for: subHabit, on: date)
    }

    /// Status describing completion for a given day.
    enum Status {
        case completed, inProgress, missed
    }

    /// Returns the completion status for a sub-habit on a date based on progress.
    func status(for subHabit: SubHabit, on date: Date) -> Status {
        let count = progress(for: subHabit, on: date)
        if count >= subHabit.target { return .completed }

        let today = Calendar.current.startOfDay(for: Date())
        let day = Calendar.current.startOfDay(for: date)
        if day < today { return .missed }
        return .inProgress
    }

    /// Returns the completion status for a main habit. A habit is complete
    /// when all of its sub-habits are completed for the specified day.
    func status(for habit: Habit, on date: Date) -> Status {
        let statuses = habit.subHabits.map { status(for: $0, on: date) }
        if statuses.allSatisfy({ $0 == .completed }) {
            return .completed
        }
        if statuses.contains(where: { $0 == .missed }) {
            return .missed
        }
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
