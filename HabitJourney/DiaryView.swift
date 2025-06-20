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
                VStack(alignment: .leading) {
                    Text("Thoughts").font(.headline)
                    Text(entry.thoughts).padding(.bottom)
                    Text("Emotions").font(.headline)
                    Text(entry.emotions)
                }
                .padding()
            } else {
                Text("No entry for \(formattedDate)")
                    .foregroundColor(.secondary)
                    .padding()
            }

            Spacer()

            Button(store.entry(for: manager.selectedDate) == nil ? "Add Entry" : "Edit Entry") {
                let existing = store.entry(for: manager.selectedDate)
                draftThoughts = existing?.thoughts ?? ""
                draftEmotions = existing?.emotions ?? ""
                showEditor = true
            }
            .padding()
        }
        .sheet(isPresented: $showEditor) {
            NavigationView {
                Form {
                    Section(header: Text("Thoughts")) {
                        TextEditor(text: $draftThoughts).frame(minHeight: 100)
                    }
                    Section(header: Text("Emotions")) {
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
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: manager.selectedDate)
    }
}

#Preview {
    DiaryView(manager: DateManager(), store: DiaryStore())
}
