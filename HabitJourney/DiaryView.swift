import SwiftUI

struct DiaryView: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: DiaryStore
    @State private var showEditor = false
    @State private var draftThoughts = ""
    @State private var draftEmotions = ""

    var body: some View {
        VStack {
            DateHeader(manager: manager)

            if let entry = store.entry(for: manager.selectedDate) {
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Thoughts")
                    } icon: {
                        Image(systemName: "lightbulb")
                    }
                    .font(.headline)
                    Text(entry.thoughts)
                    Divider()
                    Label {
                        Text("Emotions")
                    } icon: {
                        Image(systemName: "face.smiling")
                    }
                    .font(.headline)
                    Text(entry.emotions)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding()
            } else {
                Text("No entry for \(formattedDate)")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()

            Button {
                let existing = store.entry(for: manager.selectedDate)
                draftThoughts = existing?.thoughts ?? ""
                draftEmotions = existing?.emotions ?? ""
                showEditor = true
            } label: {
                if store.entry(for: manager.selectedDate) == nil {
                    Label("Add Entry", systemImage: "plus.circle")
                } else {
                    Label("Edit Entry", systemImage: "pencil.circle")
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.title2)
            .padding()
        }
        .sheet(isPresented: $showEditor) {
            NavigationView {
                Form {
                    Section(header:
                                Label {
                                    Text("Thoughts")
                                } icon: {
                                    Image(systemName: "lightbulb")
                                }
                                .font(.headline)) {
                        TextEditor(text: $draftThoughts).frame(minHeight: 100)
                    }
                    Section(header:
                                Label {
                                    Text("Emotions")
                                } icon: {
                                    Image(systemName: "face.smiling")
                                }
                                .font(.headline)) {
                        TextEditor(text: $draftEmotions).frame(minHeight: 100)
                    }
                }
                .navigationTitle("Diary Entry")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.updateEntry(for: manager.selectedDate, thoughts: draftThoughts, emotions: draftEmotions)
                            showEditor = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditor = false }
                    }
                }
            }

        }
        .background(
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: manager.selectedDate)
    }
}

#Preview {
    DiaryView(manager: DateManager(), store: DiaryStore(context: ModelController.shared.container.mainContext))
}
