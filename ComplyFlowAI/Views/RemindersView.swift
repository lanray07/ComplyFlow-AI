import SwiftData
import SwiftUI

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReminderItem.dueDate) private var reminders: [ReminderItem]
    @State private var showingEditor = false
    private let scheduler = NotificationScheduler()

    var body: some View {
        List {
            if reminders.isEmpty {
                EmptyStateView(title: "No compliance reminders", message: "Add reminders for inspections, certificates, insurance, equipment servicing, and staff training renewals.", systemImage: "bell.badge")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(reminders) { reminder in
                    VStack(alignment: .leading, spacing: 8) {
                        ReminderCard(reminder: reminder)
                        HStack {
                            Button(reminder.completed ? "Mark open" : "Mark complete") {
                                reminder.completed.toggle()
                                if reminder.completed {
                                    scheduler.cancelReminder(reminder)
                                } else {
                                    Task { await scheduler.scheduleReminder(reminder) }
                                }
                                try? modelContext.save()
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowSeparator(.hidden)
                }
                .onDelete(perform: deleteReminders)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Reminders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Label("Add reminder", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            ReminderEditorView()
        }
        .complyFlowScreenBackground()
    }

    private func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            scheduler.cancelReminder(reminder)
            modelContext.delete(reminder)
        }
        try? modelContext.save()
    }
}

private struct ReminderEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var category: ReminderCategory = .inspection
    @State private var notificationEnabled = true
    private let scheduler = NotificationScheduler()

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(ReminderCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    DatePicker("Due date", selection: $dueDate)
                    Toggle("Notify me", isOn: $notificationEnabled)
                }
            }
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveReminder() {
        let reminder = ReminderItem(title: title, dueDate: dueDate, category: category.rawValue)
        modelContext.insert(reminder)
        try? modelContext.save()
        if notificationEnabled {
            Task {
                let granted = await scheduler.requestAuthorization()
                if granted {
                    await scheduler.scheduleReminder(reminder)
                }
            }
        }
        dismiss()
    }
}

