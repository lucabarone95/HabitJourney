import Foundation

/// Categories a main habit can belong to.
enum HabitCategory: String, CaseIterable, Codable, Identifiable {
    case learning = "Learning"
    case body = "Body/Sport"
    case other = "Other"

    var id: String { rawValue }
}

/// A single sub-habit that contributes to the completion of a main habit.
struct SubHabit: Identifiable, Codable {
    let id: UUID
    var title: String
    var target: Int

    init(id: UUID = UUID(), title: String = "", target: Int = 1) {
        self.id = id
        self.title = title
        self.target = target
    }
}

/// Main habit containing a set of sub-habits. The habit is completed once all
/// sub-habits are completed for the day.
struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: HabitCategory
    var subHabits: [SubHabit]

    init(id: UUID = UUID(),
         title: String = "",
         category: HabitCategory = .other,
         subHabits: [SubHabit] = []) {
        self.id = id
        self.title = title
        self.category = category
        self.subHabits = subHabits
    }
}
