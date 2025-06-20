import SwiftUI

struct HabitsView: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: HabitStore
    @State private var showEditor = false
    @State private var habitName = ""
    @State private var target = 1

    var body: some View {
        VStack {
            DateHeader(manager: manager)

            List {
                ForEach(store.habits(for: manager.selectedDate)) { habit in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(habit.title)
                            Text("\(store.progress(for: habit, on: manager.selectedDate))/\(habit.target)")
                                .font(.caption)
                                .foregroundColor(color(for: store.status(for: habit, on: manager.selectedDate)))
                        }
                        Spacer()
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
                    }
                }
            }

            Button("Add Habit") {
                habitName = ""
                target = 1
                showEditor = true
            }
            .padding()
            .disabled(store.habits(for: manager.selectedDate).count >= 3)
        }
        .sheet(isPresented: $showEditor) {
            NavigationView {
                Form {
                    TextField("Habit", text: $habitName)
                    Stepper(value: $target, in: 1...10) {
                        Text("Target: \(target)")
                    }
                }
                .navigationTitle("New Habit")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.addHabit(title: habitName, target: target, for: manager.selectedDate)
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

    private func color(for status: HabitStore.Status) -> Color {
        switch status {
        case .completed: return .green
        case .missed: return .red
        case .inProgress: return .orange
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
