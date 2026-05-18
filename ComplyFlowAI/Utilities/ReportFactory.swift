import Foundation

enum ReportFactory {
    static func inspection(_ inspection: Inspection, business: BusinessProfile?) -> ReportContent {
        ReportContent(
            title: "\(inspection.title) Inspection Report",
            subtitle: "\(inspection.type) - \(inspection.date.formatted(date: .abbreviated, time: .omitted))",
            businessName: business?.businessName ?? "",
            sections: [
                ReportSection(title: "Business details", body: businessDetails(business)),
                ReportSection(title: "Findings", body: inspection.notes.isEmpty ? "No inspection notes recorded." : inspection.notes),
                ReportSection(title: "Pass/fail summary", body: "Passed: \(inspection.passedItems.joined(separator: ", "))\nFailed: \(inspection.failedItems.joined(separator: ", "))"),
                ReportSection(title: "AI summary", body: inspection.aiSummary.isEmpty ? "No AI analysis saved." : inspection.aiSummary),
                ReportSection(title: "Recommendations", body: inspection.aiCorrectiveActions.joined(separator: "\n")),
                ReportSection(title: "Signatures", body: "Inspector:\nSupervisor:\nDate:")
            ],
            photoData: inspection.photos.compactMap(\.imageData)
        )
    }

    static func sop(_ sop: SOPDocument, business: BusinessProfile?) -> ReportContent {
        ReportContent(
            title: sop.title,
            subtitle: "Standard Operating Procedure",
            businessName: business?.businessName ?? "",
            sections: [
                ReportSection(title: "Business details", body: businessDetails(business)),
                ReportSection(title: "Procedure", body: sop.content),
                ReportSection(title: "PPE requirements", body: sop.ppeRequirements.joined(separator: "\n")),
                ReportSection(title: "Checklist", body: sop.checklist.joined(separator: "\n")),
                ReportSection(title: "Emergency steps", body: sop.emergencySteps.joined(separator: "\n")),
                ReportSection(title: "Supervisor notes", body: sop.supervisorNotes),
                ReportSection(title: "Signatures", body: "Prepared by:\nReviewed by:\nDate:")
            ],
            photoData: []
        )
    }

    static func incident(_ incident: IncidentReport, business: BusinessProfile?) -> ReportContent {
        ReportContent(
            title: "\(incident.title) Incident Report",
            subtitle: "\(incident.type) - \(incident.createdAt.formatted(date: .abbreviated, time: .shortened))",
            businessName: business?.businessName ?? "",
            sections: [
                ReportSection(title: "Business details", body: businessDetails(business)),
                ReportSection(title: "Incident description", body: incident.incidentDescription),
                ReportSection(title: "People involved", body: incident.peopleInvolved.isEmpty ? "Not recorded." : incident.peopleInvolved),
                ReportSection(title: "Injury level", body: incident.injuryLevel),
                ReportSection(title: "Corrective action", body: incident.correctiveAction.isEmpty ? "Not recorded." : incident.correctiveAction),
                ReportSection(title: "AI incident summary", body: incident.aiSummary.isEmpty ? "No AI summary saved." : incident.aiSummary),
                ReportSection(title: "Follow-up checklist", body: incident.aiFollowUpChecklist.joined(separator: "\n")),
                ReportSection(title: "Witness notes", body: incident.witnessNotes.isEmpty ? "Not recorded." : incident.witnessNotes),
                ReportSection(title: "Signatures", body: "Reporter:\nSupervisor:\nDate:")
            ],
            photoData: incident.photoData.map { [$0] } ?? []
        )
    }

    static func audit(_ audit: AuditReport, business: BusinessProfile?) -> ReportContent {
        ReportContent(
            title: "\(audit.auditType) Summary",
            subtitle: "Audit readiness score: \(audit.score)%",
            businessName: business?.businessName ?? "",
            sections: [
                ReportSection(title: "Business details", body: businessDetails(business)),
                ReportSection(title: "Findings", body: audit.findings.joined(separator: "\n")),
                ReportSection(title: "Missing items", body: audit.missingItems.joined(separator: "\n")),
                ReportSection(title: "High-risk gaps", body: audit.highRiskGaps.joined(separator: "\n")),
                ReportSection(title: "Recommendations", body: audit.recommendations.joined(separator: "\n")),
                ReportSection(title: "Corrective action roadmap", body: audit.correctiveActionRoadmap.joined(separator: "\n")),
                ReportSection(title: "Signatures", body: "Auditor:\nManager:\nDate:")
            ],
            photoData: []
        )
    }

    private static func businessDetails(_ business: BusinessProfile?) -> String {
        guard let business else { return "Business profile not completed." }
        return """
        Name: \(business.businessName)
        Industry: \(business.industry)
        Team size: \(business.teamSize)
        Locations: \(business.locations.joined(separator: ", "))
        Safety notes: \(business.safetyNotes)
        """
    }
}

