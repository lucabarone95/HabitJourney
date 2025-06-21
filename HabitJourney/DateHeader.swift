import SwiftUI

struct DateHeader: View {
    @ObservedObject var manager: DateManager
    @ObservedObject var store: HabitStore
    @State private var showPicker = false

    var body: some View {
        HStack {
            Button(action: {
                manager.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: manager.selectedDate) ?? manager.selectedDate
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }

            Spacer()

            Button(action: { showPicker.toggle() }) {
                Text(dateString(manager.selectedDate))
                    .font(.headline)
            }
            .sheet(isPresented: $showPicker) {
                VStack {
                    CalendarView(selectedDate: $manager.selectedDate, store: store)
                        .padding()
                    Button("Done") { showPicker = false }
                        .padding()
                }
                .presentationDetents([.medium])
            }

            Spacer()

            Button(action: {
                manager.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: manager.selectedDate) ?? manager.selectedDate
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    DateHeader(manager: DateManager(), store: HabitStore())
}
