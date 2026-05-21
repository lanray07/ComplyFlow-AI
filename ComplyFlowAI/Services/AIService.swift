import Foundation
import SwiftUI

struct SOPRequest {
    var businessType: String
    var task: String
    var safetyRequirements: String
    var equipmentUsed: String
}

struct InspectionAnalysis {
    var summary: String
    var riskAreas: [String]
    var correctiveActions: [String]
    var complianceReminders: [String]
    var recommendedFollowUp: String
    var severity: Severity
    var severityScore: Int
}

struct SOPOutput {
    var title: String
    var content: String
    var safetyWarnings: [String]
    var ppeRequirements: [String]
    var checklist: [String]
    var emergencySteps: [String]
    var supervisorNotes: String
}

struct AuditSummary {
    var score: Int
    var findings: [String]
    var missingItems: [String]
    var highRiskGaps: [String]
    var recommendations: [String]
    var correctiveActionRoadmap: [String]
}

struct CorrectiveActionPlan {
    var summary: String
    var actions: [String]
    var followUpChecklist: [String]
    var targetSeverity: Severity
}

struct IncidentSummary {
    var summary: String
    var correctiveActionPlan: String
    var followUpChecklist: [String]
}

protocol AIService {
    func generateSOP(_ request: SOPRequest) async throws -> SOPOutput
    func analyzeInspection(_ inspection: Inspection, photos: [InspectionPhoto]) async throws -> InspectionAnalysis
    func generateAuditSummary(auditType: AuditKind, notes: String, businessProfile: BusinessProfile?) async throws -> AuditSummary
    func generateCorrectiveActionPlan(context: String, severity: Severity) async throws -> CorrectiveActionPlan
    func generateIncidentSummary(_ incident: IncidentReport) async throws -> IncidentSummary
}

enum AIServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "AI service is unavailable."
        }
    }
}

struct MockAIService: AIService {
    func generateSOP(_ request: SOPRequest) async throws -> SOPOutput {
        try await Task.sleep(nanoseconds: 350_000_000)
        let taskTitle = request.task.isEmpty ? "Operational Task" : request.task
        return SOPOutput(
            title: "\(taskTitle) SOP",
            content: """
            1. Confirm the work area is suitable and that the assigned person understands the task.
            2. Review the required equipment and verify it is clean, serviced, and safe to use.
            3. Complete the task following the approved sequence for \(request.businessType).
            4. Pause work if conditions change, hazards are found, or controls are not in place.
            5. Record completion notes, exceptions, and supervisor review outcomes in ComplyFlow AI.
            """,
            safetyWarnings: [
                "AI-generated SOPs must be reviewed by a competent person before use.",
                "Stop work if a hazard cannot be controlled safely.",
                "Confirm local regulatory obligations before issuing this procedure."
            ],
            ppeRequirements: [
                "Task-appropriate gloves",
                "Eye protection",
                "High-visibility clothing where vehicles or site traffic are present"
            ],
            checklist: [
                "Work area inspected",
                "Equipment condition checked",
                "PPE available and worn",
                "Emergency route identified",
                "Supervisor sign-off completed"
            ],
            emergencySteps: [
                "Stop the task and make the area safe.",
                "Contact the site supervisor or emergency services where needed.",
                "Record the incident and preserve evidence for review."
            ],
            supervisorNotes: "Review this SOP against your business controls, insurance requirements, client rules, and any applicable safety regulations before issuing it."
        )
    }

    func analyzeInspection(_ inspection: Inspection, photos: [InspectionPhoto]) async throws -> InspectionAnalysis {
        try await Task.sleep(nanoseconds: 350_000_000)
        let failedCount = inspection.failedItems.count
        let severity: Severity = failedCount >= 3 ? .high : failedCount == 2 ? .medium : Severity(rawValue: inspection.severity) ?? .low
        return InspectionAnalysis(
            summary: "\(inspection.title) was reviewed with \(inspection.passedItems.count) passed item(s), \(failedCount) failed item(s), and \(photos.count) photo(s). The notes indicate follow-up should focus on visible hazards, documentation gaps, and assigned ownership.",
            riskAreas: [
                "Incomplete close-out evidence for failed items",
                "Potential delay if corrective actions are not assigned",
                "Photo evidence should be labelled with location and context"
            ],
            correctiveActions: [
                "Assign an owner and due date for each failed item.",
                "Capture after photos when each issue is closed.",
                "Add this inspection to the next supervisor review."
            ],
            complianceReminders: [
                "Keep inspection records available for audit review.",
                "Review recurring checks for this site or asset.",
                "Escalate high or critical findings to management."
            ],
            recommendedFollowUp: "Schedule a follow-up inspection within 7 days, sooner if the risk is high or critical.",
            severity: severity,
            severityScore: min(100, 20 + failedCount * 20 + photos.count * 5)
        )
    }

    func generateAuditSummary(auditType: AuditKind, notes: String, businessProfile: BusinessProfile?) async throws -> AuditSummary {
        try await Task.sleep(nanoseconds: 350_000_000)
        let hasProfile = businessProfile?.businessName.isEmpty == false
        return AuditSummary(
            score: hasProfile ? 78 : 64,
            findings: [
                "Core operational records are present but should be organized by site and review date.",
                "Inspection evidence should include a consistent sign-off trail.",
                notes.isEmpty ? "Audit notes were not provided." : "Audit notes indicate active monitoring is underway."
            ],
            missingItems: [
                "Named owner for each recurring compliance task",
                "Documented review cadence for SOPs",
                "Central list of certificates, insurance, and servicing dates"
            ],
            highRiskGaps: [
                "Overdue corrective actions can weaken audit readiness.",
                "Unreviewed AI-generated content should not be treated as certified guidance."
            ],
            recommendations: [
                "Create reminders for expiry dates and recurring checks.",
                "Export a monthly audit readiness report.",
                "Have a qualified person review high-risk procedures."
            ],
            correctiveActionRoadmap: [
                "Week 1: Close overdue tasks and assign owners.",
                "Week 2: Review SOPs and incident records.",
                "Week 3: Export evidence pack and run supervisor review."
            ]
        )
    }

    func generateCorrectiveActionPlan(context: String, severity: Severity) async throws -> CorrectiveActionPlan {
        try await Task.sleep(nanoseconds: 250_000_000)
        return CorrectiveActionPlan(
            summary: "Create a documented corrective action plan for the \(severity.rawValue.lowercased()) issue and confirm closure evidence before marking it complete.",
            actions: [
                "Describe the issue and immediate control measures.",
                "Assign an accountable owner.",
                "Set a due date based on severity.",
                "Capture completion evidence and supervisor review."
            ],
            followUpChecklist: [
                "Owner assigned",
                "Due date agreed",
                "Evidence uploaded",
                "Reviewed by supervisor"
            ],
            targetSeverity: severity == .critical ? .high : .low
        )
    }

    func generateIncidentSummary(_ incident: IncidentReport) async throws -> IncidentSummary {
        try await Task.sleep(nanoseconds: 350_000_000)
        return IncidentSummary(
            summary: "\(incident.title) was recorded as \(incident.type.lowercased()) at \(incident.location). The report should be reviewed for immediate controls, witness information, and follow-up actions.",
            correctiveActionPlan: "Secure the area, document evidence, assign an owner for corrective actions, and complete a supervisor review before closure.",
            followUpChecklist: [
                "Confirm people involved and witness notes",
                "Attach supporting photos",
                "Record injury level and escalation decision",
                "Schedule follow-up inspection",
                "Review corrective action closure"
            ]
        )
    }
}

private struct AIServiceKey: EnvironmentKey {
    static let defaultValue: any AIService = MockAIService()
}

extension EnvironmentValues {
    var aiService: any AIService {
        get { self[AIServiceKey.self] }
        set { self[AIServiceKey.self] = newValue }
    }
}
