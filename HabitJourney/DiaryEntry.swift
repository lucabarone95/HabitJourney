import Foundation
import SwiftData

@Model
final class DiaryEntry: Identifiable {
    var id: UUID
    var date: Date
    var thoughts: String
    var emotions: String

    init(id: UUID = UUID(), date: Date = Date(), thoughts: String = "", emotions: String = "") {
        self.id = id
        self.date = date
        self.thoughts = thoughts
        self.emotions = emotions
    }
}
