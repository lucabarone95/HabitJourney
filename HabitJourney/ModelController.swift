import Foundation
import SwiftData

@MainActor
class ModelController {
    static let shared = ModelController()
    let container: ModelContainer

    private init() {
        do {
            container = try ModelContainer(for: Habit.self, SubHabit.self, DiaryEntry.self, HabitProgress.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
