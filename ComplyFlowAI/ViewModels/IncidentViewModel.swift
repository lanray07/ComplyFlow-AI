import Foundation

@MainActor
final class IncidentViewModel: ObservableObject {
    @Published var title = ""
    @Published var type: IncidentKind = .nearMiss
    @Published var location = ""
    @Published var peopleInvolved = ""
    @Published var photoData: Data?
    @Published var incidentDescription = ""
    @Published var injuryLevel: InjuryLevel = .none
    @Published var severity: Severity = .medium
    @Published var correctiveAction = ""
    @Published var witnessNotes = ""
    @Published var aiSummary: IncidentSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !incidentDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeDraftIncident() -> IncidentReport {
        IncidentReport(
            title: title,
            type: type.rawValue,
            location: location,
            peopleInvolved: peopleInvolved,
            photoData: photoData,
            incidentDescription: incidentDescription,
            injuryLevel: injuryLevel.rawValue,
            severity: severity.rawValue,
            correctiveAction: correctiveAction,
            witnessNotes: witnessNotes
        )
    }

    func generateSummary(using aiService: any AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let draft = makeDraftIncident()
            aiSummary = try await aiService.generateIncidentSummary(draft)
            correctiveAction = aiSummary?.correctiveActionPlan ?? correctiveAction
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeIncident() -> IncidentReport {
        let incident = makeDraftIncident()
        incident.aiSummary = aiSummary?.summary ?? ""
        incident.aiFollowUpChecklist = aiSummary?.followUpChecklist ?? []
        return incident
    }
}

