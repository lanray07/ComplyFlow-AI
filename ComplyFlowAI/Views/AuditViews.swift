import SwiftData
import SwiftUI

struct AuditCenterView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \AuditReport.createdAt, order: .reverse) private var audits: [AuditReport]
    @StateObject private var viewModel = AuditViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceDisclaimerView()
                if !subscriptions.isActive {
                    NavigationLink(value: AppRoute.paywall) {
                        CardSurface {
                            Label("Audit scoring is a Pro feature. Upgrade to generate readiness scores and roadmaps.", systemImage: "lock")
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                auditForm
                if viewModel.isLoading {
                    ProgressView("Generating audit summary")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                if let result = viewModel.result {
                    auditOutput(result)
                }
                previousAudits
            }
            .padding()
        }
        .navigationTitle("Audit Module")
        .complyFlowScreenBackground()
    }

    private var auditForm: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Audit type", selection: $viewModel.auditType) {
                    ForEach(AuditKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 140)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                VoiceNoteButton(text: $viewModel.notes)
                Button {
                    Task { await viewModel.generate(using: aiService, businessProfile: profiles.first) }
                } label: {
                    Label("Generate audit score", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !subscriptions.isActive)
            }
        }
    }

    private func auditOutput(_ result: AuditSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CardSurface {
                HStack {
                    Text("Audit readiness score")
                        .font(.headline)
                    Spacer()
                    Text("\(result.score)%")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.blue)
                }
            }
            DetailListCard(title: "Missing items", values: result.missingItems)
            DetailListCard(title: "High-risk gaps", values: result.highRiskGaps)
            DetailListCard(title: "Suggested improvements", values: result.recommendations)
            DetailListCard(title: "Corrective action roadmap", values: result.correctiveActionRoadmap)
            Button {
                saveAudit()
            } label: {
                Label("Save audit summary", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var previousAudits: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Previous audits")
                .font(.headline)
            if audits.isEmpty {
                EmptyStateView(title: "No audits saved", message: "Generated audit summaries will appear here.", systemImage: "clipboard")
            } else {
                ForEach(audits) { audit in
                    AuditCard(audit: audit)
                }
            }
        }
    }

    private func saveAudit() {
        guard let audit = viewModel.makeAuditReport() else { return }
        modelContext.insert(audit)
        try? modelContext.save()
    }
}
