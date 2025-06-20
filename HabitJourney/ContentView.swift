import SwiftUI

struct ContentView: View {
    @StateObject private var dateManager = DateManager()

    var body: some View {
        TabView {
            DiaryView(manager: dateManager)
                .tabItem {
                    Label("Diary", systemImage: "book")
                }
            HabitsView(manager: dateManager)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
