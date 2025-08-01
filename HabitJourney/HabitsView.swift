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

            ScrollView {
                if store.habits(for: manager.selectedDate).isEmpty {
                    Text("No habits for \(formattedDate)")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(store.habits(for: manager.selectedDate)) { habit in
                            habitCard(habit)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }

            Spacer()

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
        .background(
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
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

    private func habitHeader(_ habit: Habit) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(habit.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(habit.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if store.status(for: habit, on: manager.selectedDate) == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            Button {
                addSubParent = habit
                newSubName = ""
                newSubTarget = 1
            } label: {
                Image(systemName: "plus.circle")
            }

            Button {
                editingHabit = habit
                renameTitle = habit.title
                showRename = true
            } label: {
                Image(systemName: "pencil.circle")
            }
        }
        .padding(.bottom, 8)
    }

    private func habitCard(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            habitHeader(habit)

            ForEach(habit.subHabits) { sub in
                HStack {
                    VStack(alignment: .leading) {
                        Text(sub.title)
                        let progress = store.progress(for: sub, on: manager.selectedDate)
                        ProgressView(value: Double(min(progress, sub.target)), total: Double(sub.target))
                            .progressViewStyle(.linear)
                            .tint(color(for: store.status(for: sub, on: manager.selectedDate)))
                        Text("\(progress)/\(sub.target)")
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
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

}

#Preview {
    HabitsView(manager: DateManager(), store: HabitStore(context: ModelController.shared.container.mainContext))
}
