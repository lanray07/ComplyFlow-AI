import Foundation
import SwiftData

@Model
final class BusinessProfile {
    @Attribute(.unique) var id: UUID
    var businessName: String
    var industry: String
    var teamSize: String
    var locations: [String]
    var insuranceExpiryDates: [Date]
    var certificationExpiryDates: [Date]
    var safetyNotes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        businessName: String = "",
        industry: String = Industry.construction.rawValue,
        teamSize: String = BusinessSize.smallTeam.rawValue,
        locations: [String] = [],
        insuranceExpiryDates: [Date] = [],
        certificationExpiryDates: [Date] = [],
        safetyNotes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.businessName = businessName
        self.industry = industry
        self.teamSize = teamSize
        self.locations = locations
        self.insuranceExpiryDates = insuranceExpiryDates
        self.certificationExpiryDates = certificationExpiryDates
        self.safetyNotes = safetyNotes
        self.createdAt = createdAt
    }
}

@Model
final class Inspection {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: String
    var location: String
    var assignedUser: String
    var date: Date
    var notes: String
    var passedItems: [String]
    var failedItems: [String]
    var severity: String
    var createdAt: Date
    var aiSummary: String
    var aiRiskAreas: [String]
    var aiCorrectiveActions: [String]
    var aiComplianceReminders: [String]
    var aiRecommendedFollowUp: String
    var aiSeverityScore: Int
    @Relationship(deleteRule: .cascade, inverse: \InspectionPhoto.inspection)
    var photos: [InspectionPhoto]

    init(
        id: UUID = UUID(),
        title: String,
        type: String,
        location: String,
        assignedUser: String = "",
        date: Date = .now,
        notes: String = "",
        passedItems: [String] = [],
        failedItems: [String] = [],
        severity: String = Severity.low.rawValue,
        createdAt: Date = .now,
        aiSummary: String = "",
        aiRiskAreas: [String] = [],
        aiCorrectiveActions: [String] = [],
        aiComplianceReminders: [String] = [],
        aiRecommendedFollowUp: String = "",
        aiSeverityScore: Int = 0,
        photos: [InspectionPhoto] = []
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.location = location
        self.assignedUser = assignedUser
        self.date = date
        self.notes = notes
        self.passedItems = passedItems
        self.failedItems = failedItems
        self.severity = severity
        self.createdAt = createdAt
        self.aiSummary = aiSummary
        self.aiRiskAreas = aiRiskAreas
        self.aiCorrectiveActions = aiCorrectiveActions
        self.aiComplianceReminders = aiComplianceReminders
        self.aiRecommendedFollowUp = aiRecommendedFollowUp
        self.aiSeverityScore = aiSeverityScore
        self.photos = photos
    }
}

@Model
final class InspectionPhoto {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var localImageURL: URL?
    var caption: String
    var createdAt: Date
    var inspection: Inspection?

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        imageData: Data? = nil,
        localImageURL: URL? = nil,
        caption: String = "",
        createdAt: Date = .now,
        inspection: Inspection? = nil
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.imageData = imageData
        self.localImageURL = localImageURL
        self.caption = caption
        self.createdAt = createdAt
        self.inspection = inspection
    }
}

@Model
final class SOPDocument {
    @Attribute(.unique) var id: UUID
    var title: String
    var task: String
    var businessType: String
    var safetyRequirements: String
    var equipmentUsed: String
    var content: String
    var ppeRequirements: [String]
    var checklist: [String]
    var emergencySteps: [String]
    var supervisorNotes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        task: String,
        businessType: String,
        safetyRequirements: String,
        equipmentUsed: String,
        content: String,
        ppeRequirements: [String] = [],
        checklist: [String] = [],
        emergencySteps: [String] = [],
        supervisorNotes: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.task = task
        self.businessType = businessType
        self.safetyRequirements = safetyRequirements
        self.equipmentUsed = equipmentUsed
        self.content = content
        self.ppeRequirements = ppeRequirements
        self.checklist = checklist
        self.emergencySteps = emergencySteps
        self.supervisorNotes = supervisorNotes
        self.createdAt = createdAt
    }
}

@Model
final class IncidentReport {
    @Attribute(.unique) var id: UUID
    var title: String
    var type: String
    var location: String
    var peopleInvolved: String
    @Attribute(.externalStorage) var photoData: Data?
    var incidentDescription: String
    var injuryLevel: String
    var severity: String
    var correctiveAction: String
    var witnessNotes: String
    var aiSummary: String
    var aiFollowUpChecklist: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        type: String,
        location: String,
        peopleInvolved: String = "",
        photoData: Data? = nil,
        incidentDescription: String,
        injuryLevel: String = InjuryLevel.none.rawValue,
        severity: String = Severity.low.rawValue,
        correctiveAction: String = "",
        witnessNotes: String = "",
        aiSummary: String = "",
        aiFollowUpChecklist: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.location = location
        self.peopleInvolved = peopleInvolved
        self.photoData = photoData
        self.incidentDescription = incidentDescription
        self.injuryLevel = injuryLevel
        self.severity = severity
        self.correctiveAction = correctiveAction
        self.witnessNotes = witnessNotes
        self.aiSummary = aiSummary
        self.aiFollowUpChecklist = aiFollowUpChecklist
        self.createdAt = createdAt
    }
}

@Model
final class AuditReport {
    @Attribute(.unique) var id: UUID
    var auditType: String
    var score: Int
    var findings: [String]
    var missingItems: [String]
    var highRiskGaps: [String]
    var recommendations: [String]
    var correctiveActionRoadmap: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        auditType: String,
        score: Int,
        findings: [String] = [],
        missingItems: [String] = [],
        highRiskGaps: [String] = [],
        recommendations: [String] = [],
        correctiveActionRoadmap: [String] = [],
        createdAt: Date = .now
    ) {
        self.id = id
        self.auditType = auditType
        self.score = score
        self.findings = findings
        self.missingItems = missingItems
        self.highRiskGaps = highRiskGaps
        self.recommendations = recommendations
        self.correctiveActionRoadmap = correctiveActionRoadmap
        self.createdAt = createdAt
    }
}

@Model
final class ReminderItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date
    var category: String
    var completed: Bool

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        category: String = ReminderCategory.inspection.rawValue,
        completed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.category = category
        self.completed = completed
    }
}

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var plan: String
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: String = SubscriptionPlan.free.rawValue,
        isActive: Bool = false,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.plan = plan
        self.isActive = isActive
        self.renewsAt = renewsAt
    }
}

