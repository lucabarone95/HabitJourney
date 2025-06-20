import SwiftUI

struct HabitsView: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: HabitStore
    @State private var showEditor = false
    @State private var habitName = ""
    @State private var progress = 0


    var body: some View {
        VStack {
            DateHeader(manager: manager)

            List {
                ForEach(store.entries(for: manager.selectedDate)) { entry in
                    HStack {
                        Text(entry.name)
                        Spacer()
                        Text("\(entry.progress)")
                    }
                }
            }

            Button("Add Habit Entry") {
                habitName = ""
                progress = 0
                showEditor = true
            }
            .padding()
        }
        .sheet(isPresented: $showEditor) {
            NavigationView {
                Form {
                    TextField("Habit", text: $habitName)
                    Stepper(value: $progress, in: 0...10) {
                        Text("Progress: \(progress)")
                    }
                }
                .navigationTitle("New Habit")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.addEntry(for: manager.selectedDate, name: habitName, progress: progress)
                            showEditor = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditor = false }
                    }
                }
            }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: manager.selectedDate)
    }
}

#Preview {
    HabitsView(manager: DateManager(), store: HabitStore())
}
