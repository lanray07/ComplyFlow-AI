import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct IncidentReportsView: View {
    @Query(sort: \IncidentReport.createdAt, order: .reverse) private var incidents: [IncidentReport]

    var body: some View {
        List {
            if incidents.isEmpty {
                EmptyStateView(title: "No incidents recorded", message: "Create incident reports with photos, corrective actions, witness notes, and AI follow-up checklists.", systemImage: "cross.case")
                    .listRowBackground(Color.clear)
            } else {
                ForEach(incidents) { incident in
                    IncidentCard(incident: incident)
                        .padding(.vertical, 4)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Incidents")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.newIncident) {
                    Label("New incident", systemImage: "plus")
                }
            }
        }
        .complyFlowScreenBackground()
    }
}

struct NewIncidentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @StateObject private var viewModel = IncidentViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingCamera = false

    var body: some View {
        Form {
            Section("Incident details") {
                TextField("Title", text: $viewModel.title)
                Picker("Incident type", selection: $viewModel.type) {
                    ForEach(IncidentKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                TextField("Location", text: $viewModel.location)
                TextField("People involved", text: $viewModel.peopleInvolved, axis: .vertical)
                    .lineLimit(1...4)
                Picker("Injury level", selection: $viewModel.injuryLevel) {
                    ForEach(InjuryLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                Picker("Severity", selection: $viewModel.severity) {
                    ForEach(Severity.allCases) { severity in
                        Text(severity.rawValue).tag(severity)
                    }
                }
            }

            Section("Description") {
                TextEditor(text: $viewModel.incidentDescription)
                    .frame(minHeight: 120)
                VoiceNoteButton(text: $viewModel.incidentDescription)
            }

            Section("Photos") {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Upload photo", systemImage: "photo")
                }
                Button {
                    showingCamera = true
                } label: {
                    Label("Take photo", systemImage: "camera")
                }
                if let data = viewModel.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Section("Corrective action") {
                TextEditor(text: $viewModel.correctiveAction)
                    .frame(minHeight: 100)
                Button {
                    Task { await viewModel.generateSummary(using: aiService) }
                } label: {
                    Label("Generate incident summary", systemImage: "sparkles")
                }
                .disabled(!viewModel.canSave || viewModel.isLoading)
            }

            Section("Witness notes") {
                TextEditor(text: $viewModel.witnessNotes)
                    .frame(minHeight: 100)
                VoiceNoteButton(text: $viewModel.witnessNotes)
            }

            if viewModel.isLoading {
                ProgressView("Generating AI summary")
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            }
            if let summary = viewModel.aiSummary {
                Section("AI output") {
                    Text(summary.summary)
                    Text(summary.correctiveActionPlan)
                    ForEach(summary.followUpChecklist, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle")
                    }
                }
            }
            Section {
                ComplianceDisclaimerView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Report Incident")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveIncident()
                }
                .disabled(!viewModel.canSave)
            }
        }
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                viewModel.photoData = try? await item?.loadTransferable(type: Data.self)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(imageData: $viewModel.photoData)
        }
    }

    private func saveIncident() {
        modelContext.insert(viewModel.makeIncident())
        try? modelContext.save()
        dismiss()
    }
}

