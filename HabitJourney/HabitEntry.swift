import Foundation
import SwiftData

/// Categories a main habit can belong to.
enum HabitCategory: String, CaseIterable, Codable, Identifiable {
    case learning = "Learning"
    case body = "Body/Sport"
    case other = "Other"

    var id: String { rawValue }

    /// SFSymbol representing the category for display purposes.
    var icon: String {
        switch self {
        case .learning: return "book.fill"
        case .body: return "figure.strengthtraining.traditional"
        case .other: return "circle.grid.3x3.fill"
        }
    }
}

/// A single sub-habit that contributes to the completion of a main habit.
@Model
final class SubHabit: Identifiable {
    var id: UUID
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
@Model
final class Habit: Identifiable {
    var id: UUID
    var title: String
    var category: HabitCategory
    var subHabits: [SubHabit]
    var weekOf: Date

    init(id: UUID = UUID(),
         title: String = "",
         category: HabitCategory = .other,
         subHabits: [SubHabit] = [],
         weekOf: Date) {
        self.id = id
        self.title = title
        self.category = category
        self.subHabits = subHabits
        self.weekOf = weekOf
    }
}

@Model
final class HabitProgress: Identifiable {
    var id: UUID
    var habitID: UUID
    var subHabitID: UUID?
    var date: Date
    var count: Int

    init(id: UUID = UUID(),
         habitID: UUID,
         subHabitID: UUID? = nil,
         date: Date,
         count: Int = 0) {
        self.id = id
        self.habitID = habitID
        self.subHabitID = subHabitID
        self.date = date
        self.count = count
    }
}
