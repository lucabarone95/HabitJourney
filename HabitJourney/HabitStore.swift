import Foundation
import SwiftUI
import SwiftData

/// Stores the weekly habits and tracks daily progress for each of them.
@MainActor
class HabitStore: ObservableObject {
    /// Habits are organized by week. Each week can have at most three habits.
    @Published private var weeklyHabits: [Date: [Habit]] = [:]

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        load()
    }

    private func load() {
        let descriptor = FetchDescriptor<Habit>()
        if let items = try? context.fetch(descriptor) {
            for habit in items {
                let week = habit.weekOf
                weeklyHabits[week, default: []].append(habit)
            }
        }
    }

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
        let habit = Habit(title: title, category: category, subHabits: [sub], weekOf: week)
        context.insert(habit)
        weeklyHabits[week, default: []].append(habit)
        try? context.save()
    }

    /// Rename an existing habit in a given week.
    func renameHabit(_ habit: Habit, to newTitle: String, for date: Date) {
        habit.title = newTitle
        try? context.save()
    }

    /// Add a new sub-habit to an existing habit in the given week.
    func addSubHabit(to habit: Habit, title: String, target: Int, for date: Date) {
        habit.subHabits.append(SubHabit(title: title, target: target))
        try? context.save()
    }

    // MARK: Progress helpers


    /// Returns the progress for the given sub-habit on a specific day.
    func progress(for subHabit: SubHabit, on date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
            return 0
        }
        let subHabitID = subHabit.id
        let predicate = #Predicate<HabitProgress> { progress in
            progress.subHabitID == subHabitID &&
            progress.date >= dayStart &&
            progress.date < dayEnd
        }
        let desc = FetchDescriptor(predicate: predicate)
        return (try? context.fetch(desc).first?.count) ?? 0
    }

    /// Sets the progress for a sub-habit on the provided date.
    func setProgress(_ value: Int, for subHabit: SubHabit, on date: Date) {
        let dayStart = Calendar.current.startOfDay(for: date)
        guard let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else { return }
        let subHabitID = subHabit.id

        let predicate = #Predicate<HabitProgress> { progress in
            progress.subHabitID == subHabitID &&
            progress.date >= dayStart &&
            progress.date < dayEnd
        }
        let desc = FetchDescriptor(predicate: predicate)
        if let existing = try? context.fetch(desc).first {
            existing.count = value
        } else {
            // This assumes the sub-habit's parent habitID is the same as the sub-habit's ID
            // which might not be correct depending on your data model structure.
            let progress = HabitProgress(habitID: subHabit.id, subHabitID: subHabit.id, date: dayStart, count: value)
            context.insert(progress)
        }
        try? context.save()
    }

    /// Convenience method to increase progress by one.
    func increment(_ subHabit: SubHabit, on date: Date) {
        let current = progress(for: subHabit, on: date)
        setProgress(current + 1, for: subHabit, on: date)
    }
    // MARK: Progress helpers

    /// Returns the progress for the given habit on a specific day by summing its sub-habits.
    func progress(for habit: Habit, on date: Date) -> Int {
        habit.subHabits.reduce(0) { $0 + progress(for: $1, on: date) }
    }

    /// Sets the progress for a habit on the provided date.
    func setProgress(_ value: Int, for habit: Habit, on date: Date) {
        // distribute value across sub habits equally
        let perSub = max(1, value / max(habit.subHabits.count, 1))
        for sub in habit.subHabits {
            setProgress(perSub, for: sub, on: date)
        }
    }

    /// Convenience method to increase progress by one on the first sub habit.
    func increment(_ habit: Habit, on date: Date) {
        guard let sub = habit.subHabits.first else { return }
        increment(sub, on: date)
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

    /// Returns the completion status for a full habit on a date. A habit is
    /// completed only when all of its sub-habits are completed for the day.
    func status(for habit: Habit, on date: Date) -> Status {
        if habit.subHabits.allSatisfy({ status(for: $0, on: date) == .completed }) {
            return .completed
        }

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
