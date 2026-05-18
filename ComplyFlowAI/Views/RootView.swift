import SwiftUI

enum AppRoute: Hashable {
    case businessProfile
    case newInspection
    case sopGenerator
    case newIncident
    case auditCenter
    case reminders
    case reports
    case team
    case paywall
    case correctiveAction
    case incidents
}

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case inspections = "Inspections"
    case aiTools = "AI Tools"
    case reports = "Reports"
    case profile = "Profile"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dashboard:
            "gauge.with.dots.needle.67percent"
        case .inspections:
            "checklist"
        case .aiTools:
            "sparkles"
        case .reports:
            "doc.richtext"
        case .profile:
            "building.2"
        }
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            AppShellView()
        } else {
            OnboardingView()
        }
    }
}

struct AppShellView: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tabContent(tab)
                        .withAppDestinations()
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.systemImage)
                }
                .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(_ tab: AppTab) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .inspections:
            InspectionListView()
        case .aiTools:
            AIToolsView()
        case .reports:
            ReportsCenterView()
        case .profile:
            BusinessProfileView()
        }
    }
}

private extension View {
    func withAppDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .businessProfile:
                BusinessProfileView()
            case .newInspection:
                InspectionEditorView()
            case .sopGenerator:
                SOPGeneratorView()
            case .newIncident:
                NewIncidentView()
            case .auditCenter:
                AuditCenterView()
            case .reminders:
                RemindersView()
            case .reports:
                ReportsCenterView()
            case .team:
                TeamManagementView()
            case .paywall:
                PaywallView()
            case .correctiveAction:
                CorrectiveActionPlanView()
            case .incidents:
                IncidentReportsView()
            }
        }
    }
}
