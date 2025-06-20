import SwiftUI

struct HabitsView: View {
    @ObservedObject var manager: DateManager

    var body: some View {
        VStack {
            DateHeader(manager: manager)
            Spacer()
            Text("Habits for \(formattedDate)")
            Spacer()
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: manager.selectedDate)
    }
}

#Preview {
    HabitsView(manager: DateManager())
}
