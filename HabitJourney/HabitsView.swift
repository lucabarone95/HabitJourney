import SwiftUI

struct HabitsView: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: HabitStore
    @State private var showEditor = false
    @State private var habitName = ""
    @State private var category: HabitCategory = .other
    @State private var subHabitName = ""
    @State private var target = 1

    @State private var editingHabit: Habit?
    @State private var renameTitle = ""
    @State private var showRename = false
    @State private var newSubName = ""
    @State private var newSubTarget = 1
    @State private var addSubParent: Habit?


    var body: some View {
        VStack {
            DateHeader(manager: manager)

            List {
                ForEach(store.habits(for: manager.selectedDate)) { habit in
                    Section(header: habitHeader(habit)) {
                        ForEach(habit.subHabits) { sub in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(sub.title)
                                    ProgressView(value: Double(store.progress(for: sub, on: manager.selectedDate)), total: Double(sub.target))
                                        .progressViewStyle(.linear)
                                        .tint(color(for: store.status(for: sub, on: manager.selectedDate)))
                                    Text("\(store.progress(for: sub, on: manager.selectedDate))/\(sub.target)")
                                        .font(.caption)
                                        .foregroundColor(color(for: store.status(for: sub, on: manager.selectedDate)))
                                }
                                Spacer()
                                if store.status(for: sub, on: manager.selectedDate) != .completed {
                                    Button(action: { store.increment(sub, on: manager.selectedDate) }) {
                                        Image(systemName: "plus.circle")
                                    }
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }

                        }
                    }
                }
            }
            .listStyle(.insetGrouped)

            Button("Add Habit") {
                habitName = ""
                subHabitName = ""
                target = 1
                category = .other

                showEditor = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled(store.habits(for: manager.selectedDate).count >= 3)
        }
        .sheet(isPresented: $showEditor) {
            NavigationView {
                Form {
                    Section("Main Habit") {
                        TextField("Title", text: $habitName)
                        Picker("Category", selection: $category) {
                            ForEach(HabitCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    }
                    Section("First Sub-Habit") {
                        TextField("Title", text: $subHabitName)
                        Stepper(value: $target, in: 1...10) {
                            Text("Target: \(target)")
                        }

                    }
                }
                .navigationTitle("New Habit")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.addHabit(title: habitName,
                                           category: category,
                                           subHabitTitle: subHabitName,
                                           target: target,
                                           for: manager.selectedDate)

                            showEditor = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditor = false }
                    }
                }
            }
        }

        .sheet(isPresented: $showRename) {
            if let habit = editingHabit {
                NavigationView {
                    Form {
                        TextField("Title", text: $renameTitle)
                    }
                    .navigationTitle("Rename Habit")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                store.renameHabit(habit, to: renameTitle, for: manager.selectedDate)
                                showRename = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showRename = false }
                        }
                    }
                }
            }
        }

        .sheet(item: $addSubParent) { habit in
            NavigationView {
                Form {
                    TextField("Title", text: $newSubName)
                    Stepper(value: $newSubTarget, in: 1...10) {
                        Text("Target: \(newSubTarget)")
                    }
                }
                .navigationTitle("New Sub-Habit")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.addSubHabit(to: habit,
                                              title: newSubName,
                                              target: newSubTarget,
                                              for: manager.selectedDate)
                            addSubParent = nil
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { addSubParent = nil }
                    }
                }
            }
        }
        }
        .background(
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )


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

    private func habitHeader(_ habit: Habit) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.title)
                Text(habit.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if store.status(for: habit, on: manager.selectedDate) == .completed {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            }
            Menu {
                Button("Rename") {
                    editingHabit = habit
                    renameTitle = habit.title
                    showRename = true
                }
                Button("Add Sub Habit") {
                    addSubParent = habit
                    newSubName = ""
                    newSubTarget = 1
                }
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .padding(.leading, 4)
            }
        }
    }

}

#Preview {
    HabitsView(manager: DateManager(), store: HabitStore())
}
