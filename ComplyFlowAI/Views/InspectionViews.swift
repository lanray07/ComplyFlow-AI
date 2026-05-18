import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct InspectionListView: View {
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]

    var body: some View {
        List {
            if inspections.isEmpty {
                EmptyStateView(title: "No inspections yet", message: "Create a vehicle, site, PPE, equipment, fire safety, cleaning, property, contractor, or warehouse check.", systemImage: "checklist")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(inspections) { inspection in
                    NavigationLink {
                        InspectionAnalysisView(inspection: inspection)
                    } label: {
                        InspectionCard(inspection: inspection)
                            .padding(.vertical, 4)
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Inspections")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.newInspection) {
                    Label("New inspection", systemImage: "plus")
                }
            }
        }
        .complyFlowScreenBackground()
    }
}

struct InspectionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @Query(sort: \Inspection.createdAt, order: .reverse) private var existingInspections: [Inspection]
    @StateObject private var viewModel = InspectionEditorViewModel()
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var cameraImageData: Data?

    var body: some View {
        Form {
            Section("Inspection details") {
                TextField("Inspection title", text: $viewModel.title)
                Picker("Type", selection: $viewModel.type) {
                    ForEach(InspectionKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                TextField("Site or location", text: $viewModel.location)
                TextField("Assigned user", text: $viewModel.assignedUser)
                DatePicker("Date", selection: $viewModel.date)
                Picker("Risk level", selection: $viewModel.severity) {
                    ForEach(Severity.allCases) { severity in
                        Text(severity.rawValue).tag(severity)
                    }
                }
            }

            Section("Notes") {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 120)
                VoiceNoteButton(text: $viewModel.notes)
            }

            Section("Pass/fail items") {
                ForEach(viewModel.checklistOptions, id: \.self) { item in
                    ChecklistResultRow(
                        title: item,
                        passed: Binding(
                            get: { viewModel.passedItems.contains(item) },
                            set: { viewModel.togglePassed(item, isOn: $0) }
                        ),
                        failed: Binding(
                            get: { viewModel.failedItems.contains(item) },
                            set: { viewModel.toggleFailed(item, isOn: $0) }
                        )
                    )
                }
            }

            Section("Photos") {
                PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 6, matching: .images) {
                    Label("Upload photos", systemImage: "photo.on.rectangle")
                }
                Button {
                    showingCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera")
                }
                if viewModel.isImportingPhotos {
                    ProgressView("Importing photos")
                }
                PhotoDraftGrid(photoDrafts: $viewModel.photoDrafts)
            }

            if hasReachedFreeLimit {
                Section {
                    NavigationLink(value: AppRoute.paywall) {
                        Label("Free plan limit reached. Upgrade for unlimited inspections.", systemImage: "lock")
                    }
                }
            }

            ComplianceDisclaimerView()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
        .navigationTitle("New Inspection")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveInspection()
                }
                .disabled(!viewModel.canSave || hasReachedFreeLimit)
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task { await viewModel.importPhotos(newItems) }
        }
        .onChange(of: cameraImageData) { _, newData in
            viewModel.addCameraImage(newData)
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(imageData: $cameraImageData)
        }
    }

    private func saveInspection() {
        modelContext.insert(viewModel.makeInspection())
        try? modelContext.save()
        dismiss()
    }

    private var hasReachedFreeLimit: Bool {
        !subscriptions.isActive && existingInspections.filter { Calendar.current.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }.count >= 3
    }
}

struct InspectionAnalysisView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Bindable var inspection: Inspection
    @StateObject private var viewModel = InspectionAnalysisViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                InspectionCard(inspection: inspection)
                ComplianceDisclaimerView()
                if !inspection.aiSummary.isEmpty {
                    savedAnalysis
                }
                if let result = viewModel.result {
                    generatedAnalysis(result)
                }
                if viewModel.isLoading {
                    ProgressView("Analyzing inspection")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                Button {
                    Task {
                        await viewModel.analyze(inspection: inspection, aiService: aiService)
                        viewModel.applyResult(to: inspection)
                        try? modelContext.save()
                    }
                } label: {
                    Label(inspection.aiSummary.isEmpty ? "Analyze inspection" : "Refresh AI analysis", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("AI Analysis")
        .complyFlowScreenBackground()
    }

    private var savedAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            AnalysisSection(title: "Inspection summary", values: [inspection.aiSummary])
            AnalysisSection(title: "Possible risk areas", values: inspection.aiRiskAreas)
            AnalysisSection(title: "Corrective actions", values: inspection.aiCorrectiveActions)
            AnalysisSection(title: "Compliance reminders", values: inspection.aiComplianceReminders)
            AnalysisSection(title: "Recommended follow-up", values: [inspection.aiRecommendedFollowUp])
            CardSurface {
                HStack {
                    Text("Severity score")
                        .font(.headline)
                    Spacer()
                    Text("\(inspection.aiSeverityScore)")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }
            }
        }
    }

    private func generatedAnalysis(_ result: InspectionAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            AnalysisSection(title: "Generated summary", values: [result.summary])
            AnalysisSection(title: "Generated corrective actions", values: result.correctiveActions)
        }
    }
}

private struct ChecklistResultRow: View {
    let title: String
    @Binding var passed: Bool
    @Binding var failed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
            HStack {
                Toggle("Pass", isOn: $passed)
                    .toggleStyle(.button)
                    .tint(.green)
                Toggle("Fail", isOn: $failed)
                    .toggleStyle(.button)
                    .tint(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PhotoDraftGrid: View {
    @Binding var photoDrafts: [PhotoDraft]

    var body: some View {
        if !photoDrafts.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                ForEach($photoDrafts) { $draft in
                    VStack(alignment: .leading, spacing: 6) {
                        if let image = UIImage(data: draft.data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        TextField("Caption", text: $draft.caption)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

private struct AnalysisSection: View {
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
