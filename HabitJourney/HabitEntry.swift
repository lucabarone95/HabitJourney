import Foundation

/// Basic habit definition that repeats every day for the week.
struct Habit: Identifiable, Codable {
    /// Stable identifier for the habit.
    let id: UUID
    /// Short title shown in the list.
    var title: String
    /// Target count required to mark the habit complete for a day.
    var target: Int

    init(id: UUID = UUID(), title: String = "", target: Int = 1) {
        self.id = id
        self.title = title
        self.target = target

    }
}
