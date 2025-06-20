import SwiftUI

struct ContentView: View {
    @StateObject private var dateManager = DateManager()
    @StateObject private var diaryStore = DiaryStore()
    @StateObject private var habitStore = HabitStore()

    var body: some View {
        TabView {
            DiaryView(manager: dateManager, store: diaryStore)
                .tabItem {
                    Label("Diary", systemImage: "book")
                }
            HabitsView(manager: dateManager, store: habitStore)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
