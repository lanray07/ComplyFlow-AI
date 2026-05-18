import SwiftUI

struct AIToolsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI tools")
                        .font(.title.bold())
                    Text("Generate SOPs, audit summaries, incident follow-ups, and corrective action plans.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ComplianceDisclaimerView()

                NavigationTile(title: "SOP Generator", subtitle: "Create editable operating procedures and export PDFs.", systemImage: "doc.badge.gearshape", route: .sopGenerator)
                NavigationTile(title: "Audit Module", subtitle: "Score readiness, find gaps, and create a roadmap.", systemImage: "clipboard", route: .auditCenter)
                NavigationTile(title: "Incident Reporting", subtitle: "Record incidents and generate follow-up checklists.", systemImage: "cross.case", route: .incidents)
                NavigationTile(title: "Corrective Action Plan", subtitle: "Turn findings into owner-ready action steps.", systemImage: "wrench.and.screwdriver", route: .correctiveAction)
            }
            .padding()
        }
        .navigationTitle("AI Tools")
        .complyFlowScreenBackground()
    }
}

private struct NavigationTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            CardSurface {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 34)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(subtitle)
                            .font(.subheadline)
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
}
