import SwiftUI

struct DateHeader: View {
    @ObservedObject var manager: DateManager
    @State private var showPicker = false

    var body: some View {
        HStack {
            Button(action: {
                manager.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: manager.selectedDate) ?? manager.selectedDate
            }) {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Button(action: { showPicker.toggle() }) {
                Text(dateString(manager.selectedDate))
                    .font(.headline)
            }
            .sheet(isPresented: $showPicker) {
                VStack {
                    DatePicker("Select Date", selection: $manager.selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
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
    DateHeader(manager: DateManager())
}
