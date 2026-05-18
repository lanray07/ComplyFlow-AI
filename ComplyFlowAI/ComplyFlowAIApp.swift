import SwiftData
import SwiftUI

@main
struct ComplyFlowAIApp: App {
    @StateObject private var subscriptions = SubscriptionManager()

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BusinessProfile.self,
            Inspection.self,
            InspectionPhoto.self,
            SOPDocument.self,
            IncidentReport.self,
            AuditReport.self,
            ReminderItem.self,
            SubscriptionState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(subscriptions)
                .environment(\.aiService, MockAIService())
                .task {
                    await subscriptions.start()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
