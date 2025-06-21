import Foundation
import SwiftUI
import SwiftData

@MainActor
class DiaryStore: ObservableObject {
    @Published private(set) var entries: [Date: DiaryEntry] = [:]
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        load()
    }

    private func load() {
        let descriptor = FetchDescriptor<DiaryEntry>()
        if let items = try? context.fetch(descriptor) {
            for entry in items {
                let day = Calendar.current.startOfDay(for: entry.date)
                entries[day] = entry
            }
        }
    }

    func entry(for date: Date) -> DiaryEntry? {
        let day = Calendar.current.startOfDay(for: date)
        return entries[day]
    }

    func updateEntry(for date: Date, thoughts: String, emotions: String) {
        let day = Calendar.current.startOfDay(for: date)
        if let existing = entries[day] {
            existing.thoughts = thoughts
            existing.emotions = emotions
            existing.date = day
        } else {
            let entry = DiaryEntry(date: day, thoughts: thoughts, emotions: emotions)
            context.insert(entry)
            entries[day] = entry
        }
        try? context.save()
    }
}
