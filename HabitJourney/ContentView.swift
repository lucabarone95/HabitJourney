import SwiftUI

struct ContentView: View {
    @StateObject private var dateManager = DateManager()
    @StateObject private var diaryStore = DiaryStore()
    @StateObject private var habitStore = HabitStore()

    var body: some View {
        TabView {
            NavigationStack {
                DiaryView(manager: dateManager, store: diaryStore)
                    .navigationTitle("Diary")
            }
            .tabItem {
                Label("Diary", systemImage: "book")
            }

            NavigationStack {
                HabitsView(manager: dateManager, store: habitStore)
                    .navigationTitle("Habits")
            }
            .tabItem {
                Label("Habits", systemImage: "checkmark.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}
