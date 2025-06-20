import Foundation

struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    var thoughts: String
    var emotions: String
    
    init(id: UUID = UUID(), thoughts: String = "", emotions: String = "") {
        self.id = id
        self.thoughts = thoughts
        self.emotions = emotions
    }
}
