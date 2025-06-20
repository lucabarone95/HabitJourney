import Foundation
import SwiftUI

class DiaryStore: ObservableObject {
    @Published private(set) var entries: [Date: DiaryEntry] = [:]
    
    func entry(for date: Date) -> DiaryEntry? {
        let day = Calendar.current.startOfDay(for: date)
        return entries[day]
    }
    
    func updateEntry(for date: Date, thoughts: String, emotions: String) {
        let day = Calendar.current.startOfDay(for: date)
        let entry = DiaryEntry(thoughts: thoughts, emotions: emotions)
        entries[day] = entry
    }
}
