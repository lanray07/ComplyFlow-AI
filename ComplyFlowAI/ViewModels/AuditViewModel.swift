import Foundation

@MainActor
final class AuditViewModel: ObservableObject {
    @Published var auditType: AuditKind = .safety
    @Published var notes = ""
    @Published var result: AuditSummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func generate(using aiService: any AIService, businessProfile: BusinessProfile?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            result = try await aiService.generateAuditSummary(auditType: auditType, notes: notes, businessProfile: businessProfile)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeAuditReport() -> AuditReport? {
        guard let result else { return nil }
        return AuditReport(
            auditType: auditType.rawValue,
            score: result.score,
            findings: result.findings,
            missingItems: result.missingItems,
            highRiskGaps: result.highRiskGaps,
            recommendations: result.recommendations,
            correctiveActionRoadmap: result.correctiveActionRoadmap
        )
    }
}

