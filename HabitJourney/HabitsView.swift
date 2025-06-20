import SwiftUI

struct HabitsView: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: HabitStore
    @State private var showEditor = false
    @State private var habitName = ""
    @State private var target = 1


                ForEach(store.habits) { habit in
                        VStack(alignment: .leading) {
                            Text(habit.title)
                            Text("\(store.progress(for: habit, on: manager.selectedDate))/\(habit.target)")
                                .font(.caption)
                                .foregroundColor(color(for: store.status(for: habit, on: manager.selectedDate)))
                        }
                        if store.status(for: habit, on: manager.selectedDate) != .completed {
                            Button(action: {
                                store.increment(habit, on: manager.selectedDate)
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }

            Button("Add Habit") {
                target = 1
            .disabled(store.habits.count >= 3)
                    Stepper(value: $target, in: 1...10) {
                        Text("Target: \(target)")
                            store.addHabit(title: habitName, target: target)
    private func color(for status: HabitStore.Status) -> Color {
        switch status {
        case .completed: return .green
        case .missed: return .red
        case .inProgress: return .orange
        }
    }

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
