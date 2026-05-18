import Foundation
import PhotosUI

struct PhotoDraft: Identifiable {
    let id = UUID()
    var data: Data
    var caption: String = ""
}

@MainActor
final class InspectionEditorViewModel: ObservableObject {
    @Published var title = ""
    @Published var type: InspectionKind = .site
    @Published var location = ""
    @Published var assignedUser = ""
    @Published var date = Date()
    @Published var notes = ""
    @Published var severity: Severity = .low
    @Published var passedItems: Set<String> = []
    @Published var failedItems: Set<String> = []
    @Published var photoDrafts: [PhotoDraft] = []
    @Published var isImportingPhotos = false
    @Published var errorMessage: String?

    let checklistOptions = [
        "Access route clear",
        "PPE available and worn",
        "Equipment condition acceptable",
        "Emergency information visible",
        "Housekeeping acceptable",
        "Training or certification current"
    ]

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func togglePassed(_ item: String, isOn: Bool) {
        if isOn {
            passedItems.insert(item)
            failedItems.remove(item)
        } else {
            passedItems.remove(item)
        }
    }

    func toggleFailed(_ item: String, isOn: Bool) {
        if isOn {
            failedItems.insert(item)
            passedItems.remove(item)
        } else {
            failedItems.remove(item)
        }
    }

    func importPhotos(_ items: [PhotosPickerItem]) async {
        isImportingPhotos = true
        defer { isImportingPhotos = false }
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    photoDrafts.append(PhotoDraft(data: data))
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func addCameraImage(_ data: Data?) {
        guard let data else { return }
        photoDrafts.append(PhotoDraft(data: data))
    }

    func makeInspection() -> Inspection {
        let inspection = Inspection(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type.rawValue,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            assignedUser: assignedUser.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            passedItems: Array(passedItems).sorted(),
            failedItems: Array(failedItems).sorted(),
            severity: severity.rawValue
        )
        inspection.photos = photoDrafts.map {
            InspectionPhoto(inspectionId: inspection.id, imageData: $0.data, caption: $0.caption, inspection: inspection)
        }
        return inspection
    }
}

@MainActor
final class InspectionAnalysisViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var result: InspectionAnalysis?

    func analyze(inspection: Inspection, aiService: any AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            result = try await aiService.analyzeInspection(inspection, photos: inspection.photos)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyResult(to inspection: Inspection) {
        guard let result else { return }
        inspection.aiSummary = result.summary
        inspection.aiRiskAreas = result.riskAreas
        inspection.aiCorrectiveActions = result.correctiveActions
        inspection.aiComplianceReminders = result.complianceReminders
        inspection.aiRecommendedFollowUp = result.recommendedFollowUp
        inspection.aiSeverityScore = result.severityScore
        inspection.severity = result.severity.rawValue
    }
}

