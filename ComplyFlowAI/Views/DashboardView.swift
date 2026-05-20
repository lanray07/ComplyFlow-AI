import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Query(sort: \Inspection.date) private var inspections: [Inspection]
    @Query(sort: \IncidentReport.createdAt, order: .reverse) private var incidents: [IncidentReport]
    @Query(sort: \AuditReport.createdAt, order: .reverse) private var audits: [AuditReport]
    @Query(sort: \ReminderItem.dueDate) private var reminders: [ReminderItem]
    @Query(sort: \SOPDocument.createdAt, order: .reverse) private var sops: [SOPDocument]

    private var upcomingInspections: [Inspection] {
        inspections.filter { $0.date >= Calendar.current.startOfDay(for: .now) }.prefix(3).map { $0 }
    }

    private var overdueTasks: [ReminderItem] {
        reminders.filter { !$0.completed && $0.dueDate < .now }
    }

    private var openIncidents: [IncidentReport] {
        incidents.filter { $0.correctiveAction.isEmpty || !$0.aiFollowUpChecklist.isEmpty }
    }

    private var auditReadinessScore: Int {
        audits.first?.score ?? max(35, 80 - overdueTasks.count * 8 - openIncidents.count * 4)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                metricsGrid
                quickActions
                subscriptionCard
                upcomingSection
                remindersSection
                recentReportsSection
            }
            .padding()
        }
        .navigationTitle("ComplyFlow AI")
        .complyFlowScreenBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Operations dashboard")
                .font(.title.bold())
            Text("Inspections, incidents, audit readiness, and reminders at a glance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Audit readiness", value: "\(auditReadinessScore)%", systemImage: "chart.line.uptrend.xyaxis", tint: .blue)
            MetricCard(title: "Open incidents", value: "\(openIncidents.count)", systemImage: "cross.case", tint: .orange)
            MetricCard(title: "Overdue tasks", value: "\(overdueTasks.count)", systemImage: "clock.badge.exclamationmark", tint: overdueTasks.isEmpty ? .green : .red)
            MetricCard(title: "Reports", value: "\(inspections.count + incidents.count + audits.count + sops.count)", systemImage: "doc.text", tint: .purple)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick actions")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                QuickActionLink(title: "New Inspection", systemImage: "checklist", route: .newInspection)
                QuickActionLink(title: "New Audit", systemImage: "clipboard", route: .auditCenter)
                QuickActionLink(title: "Generate SOP", systemImage: "doc.badge.gearshape", route: .sopGenerator)
                QuickActionLink(title: "Report Incident", systemImage: "cross.case", route: .newIncident)
                QuickActionLink(title: "Create Checklist", systemImage: "list.bullet.clipboard", route: .newInspection)
                QuickActionLink(title: "Corrective Plan", systemImage: "wrench.and.screwdriver", route: .correctiveAction)
                QuickActionLink(title: "View Plans", systemImage: "creditcard", route: .paywall)
            }
        }
    }

    private var subscriptionCard: some View {
        NavigationLink(value: AppRoute.paywall) {
            CardSurface {
                HStack(spacing: 12) {
                    Image(systemName: "creditcard")
                        .foregroundStyle(.blue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Subscription status")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(subscriptions.subscriptionStatusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Tap to view Pro, Pro Yearly, and Business subscriptions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming inspections")
                .font(.headline)
            if upcomingInspections.isEmpty {
                EmptyStateView(title: "No inspections scheduled", message: "Create a site, vehicle, PPE, equipment, cleaning, or property inspection.", systemImage: "calendar.badge.plus")
            } else {
                ForEach(upcomingInspections) { inspection in
                    NavigationLink {
                        InspectionAnalysisView(inspection: inspection)
                    } label: {
                        InspectionCard(inspection: inspection)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Compliance reminders")
                    .font(.headline)
                Spacer()
                NavigationLink("View all", value: AppRoute.reminders)
                    .font(.subheadline)
            }
            if reminders.isEmpty {
                EmptyStateView(title: "No reminders yet", message: "Track inspection due dates, certificate expiry, insurance renewal, equipment servicing, and training.", systemImage: "bell.badge")
            } else {
                ForEach(reminders.prefix(3)) { reminder in
                    ReminderCard(reminder: reminder)
                }
            }
        }
    }

    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent reports")
                    .font(.headline)
                Spacer()
                NavigationLink("Reports", value: AppRoute.reports)
                    .font(.subheadline)
            }
            if inspections.isEmpty && incidents.isEmpty && audits.isEmpty && sops.isEmpty {
                EmptyStateView(title: "No reports generated", message: "Saved inspections, incidents, SOPs, and audits appear here for export.", systemImage: "doc.badge.plus")
            } else {
                ForEach(inspections.prefix(2)) { inspection in
                    InspectionCard(inspection: inspection)
                }
            }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(tint)
                Text(value)
                    .font(.title.bold())
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct QuickActionLink: View {
    let title: String
    let systemImage: String
    let route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            CardSurface {
                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .foregroundStyle(.blue)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
