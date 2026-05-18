import SwiftData
import SwiftUI

struct SOPGeneratorView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \SOPDocument.createdAt, order: .reverse) private var savedSOPs: [SOPDocument]
    @StateObject private var viewModel = SOPGeneratorViewModel()
    @State private var shareItem: ShareItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceDisclaimerView()
                inputForm
                if viewModel.isLoading {
                    ProgressView("Generating SOP")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                if hasReachedFreeLimit {
                    NavigationLink(value: AppRoute.paywall) {
                        CardSurface {
                            Label("Free plan includes 1 SOP per month. Upgrade for unlimited SOP generation.", systemImage: "lock")
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                if let output = viewModel.output {
                    generatedOutput(output)
                }
            }
            .padding()
        }
        .navigationTitle("SOP Generator")
        .complyFlowScreenBackground()
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    private var inputForm: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Business type", selection: $viewModel.businessType) {
                    ForEach(Industry.allCases) { industry in
                        Text(industry.rawValue).tag(industry.rawValue)
                    }
                }
                TextField("Task", text: $viewModel.task)
                TextField("Safety requirements", text: $viewModel.safetyRequirements, axis: .vertical)
                    .lineLimit(2...5)
                TextField("Equipment used", text: $viewModel.equipmentUsed, axis: .vertical)
                    .lineLimit(2...5)
                Button {
                    Task { await viewModel.generate(using: aiService) }
                } label: {
                    Label("Generate SOP", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canGenerate || viewModel.isLoading || hasReachedFreeLimit)
            }
        }
    }

    private func generatedOutput(_ output: SOPOutput) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            CardSurface {
                VStack(alignment: .leading, spacing: 10) {
                    Text(output.title)
                        .font(.title3.bold())
                    TextEditor(text: $viewModel.editableContent)
                        .frame(minHeight: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary)
                        )
                }
            }
            DetailListCard(title: "Safety warnings", values: output.safetyWarnings)
            DetailListCard(title: "PPE requirements", values: output.ppeRequirements)
            DetailListCard(title: "Checklist", values: output.checklist)
            DetailListCard(title: "Emergency steps", values: output.emergencySteps)
            DetailListCard(title: "Supervisor notes", values: [output.supervisorNotes])
            HStack {
                Button {
                    saveSOP()
                } label: {
                    Label("Save SOP", systemImage: "tray.and.arrow.down")
                }
                .buttonStyle(.borderedProminent)

                if subscriptions.isActive {
                    Button {
                        exportSOP(output)
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                } else {
                    NavigationLink(value: AppRoute.paywall) {
                        Label("PDF export", systemImage: "lock")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private func saveSOP() {
        guard let document = viewModel.makeDocument() else { return }
        modelContext.insert(document)
        try? modelContext.save()
    }

    private func exportSOP(_ output: SOPOutput) {
        guard let document = viewModel.makeDocument() else { return }
        let report = ReportFactory.sop(document, business: profiles.first)
        if let url = try? PDFExportService().generatePDF(for: report) {
            shareItem = ShareItem(url: url)
        }
    }

    private var hasReachedFreeLimit: Bool {
        !subscriptions.isActive && savedSOPs.filter { Calendar.current.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }.count >= 1
    }
}

struct CorrectiveActionPlanView: View {
    @Environment(\.aiService) private var aiService
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @State private var context = ""
    @State private var severity: Severity = .medium
    @State private var result: CorrectiveActionPlan?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceDisclaimerView()
                if !subscriptions.isActive {
                    NavigationLink(value: AppRoute.paywall) {
                        CardSurface {
                            Label("AI corrective action plans are a Pro feature.", systemImage: "lock")
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                CardSurface {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Severity", selection: $severity) {
                            ForEach(Severity.allCases) { severity in
                                Text(severity.rawValue).tag(severity)
                            }
                        }
                        TextEditor(text: $context)
                            .frame(minHeight: 140)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                        VoiceNoteButton(text: $context)
                        Button {
                            generatePlan()
                        } label: {
                            Label("Generate plan", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading || !subscriptions.isActive)
                    }
                }

                if isLoading {
                    ProgressView("Generating corrective action plan")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                if let result {
                    DetailListCard(title: "Summary", values: [result.summary])
                    DetailListCard(title: "Actions", values: result.actions)
                    DetailListCard(title: "Follow-up checklist", values: result.followUpChecklist)
                    CardSurface {
                        HStack {
                            Text("Target severity")
                                .font(.headline)
                            Spacer()
                            SeverityBadge(result.targetSeverity)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Corrective Plan")
        .complyFlowScreenBackground()
    }

    private func generatePlan() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                result = try await aiService.generateCorrectiveActionPlan(context: context, severity: severity)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct DetailListCard: View {
    let title: String
    let values: [String]

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                ForEach(values.filter { !$0.isEmpty }, id: \.self) { value in
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
