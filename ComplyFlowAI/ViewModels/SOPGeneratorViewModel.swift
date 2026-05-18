import Foundation

@MainActor
final class SOPGeneratorViewModel: ObservableObject {
    @Published var businessType = Industry.construction.rawValue
    @Published var task = ""
    @Published var safetyRequirements = ""
    @Published var equipmentUsed = ""
    @Published var output: SOPOutput?
    @Published var editableContent = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var canGenerate: Bool {
        !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func generate(using aiService: any AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let result = try await aiService.generateSOP(SOPRequest(
                businessType: businessType,
                task: task,
                safetyRequirements: safetyRequirements,
                equipmentUsed: equipmentUsed
            ))
            output = result
            editableContent = result.content
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeDocument() -> SOPDocument? {
        guard let output else { return nil }
        return SOPDocument(
            title: output.title,
            task: task,
            businessType: businessType,
            safetyRequirements: safetyRequirements,
            equipmentUsed: equipmentUsed,
            content: editableContent,
            ppeRequirements: output.ppeRequirements,
            checklist: output.checklist,
            emergencySteps: output.emergencySteps,
            supervisorNotes: output.supervisorNotes
        )
    }
}

