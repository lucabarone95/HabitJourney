import Foundation
import SwiftUI

class HabitStore: ObservableObject {
    @Published private(set) var entries: [Date: [HabitEntry]] = [:]
    
    func entries(for date: Date) -> [HabitEntry] {
        let day = Calendar.current.startOfDay(for: date)
        return entries[day] ?? []
    }
    
    func addEntry(for date: Date, name: String, progress: Int) {
        let day = Calendar.current.startOfDay(for: date)
        let entry = HabitEntry(name: name, progress: progress)
        entries[day, default: []].append(entry)
    }
}
