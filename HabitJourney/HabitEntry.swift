import Foundation

struct HabitEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var progress: Int
    
    init(id: UUID = UUID(), name: String = "", progress: Int = 0) {
        self.id = id
        self.name = name
        self.progress = progress
    }
}
