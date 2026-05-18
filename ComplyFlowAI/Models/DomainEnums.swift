import Foundation

enum Industry: String, CaseIterable, Identifiable, Codable {
    case construction = "Construction"
    case roofing = "Roofing"
    case landscaping = "Landscaping"
    case logistics = "Logistics"
    case cleaning = "Cleaning"
    case warehousing = "Warehousing"
    case propertyManagement = "Property Management"
    case facilities = "Facilities"
    case other = "Other"

    var id: String { rawValue }
}

enum BusinessSize: String, CaseIterable, Identifiable, Codable {
    case solo = "Solo"
    case smallTeam = "Small Team"
    case multiSite = "Multi-Site Business"

    var id: String { rawValue }
}

enum InspectionKind: String, CaseIterable, Identifiable, Codable {
    case vehicle = "Vehicle inspection"
    case site = "Site inspection"
    case ppe = "PPE inspection"
    case equipment = "Equipment inspection"
    case fireSafety = "Fire safety check"
    case cleaning = "Cleaning inspection"
    case property = "Property inspection"
    case contractor = "Contractor inspection"
    case warehouse = "Warehouse safety check"
    case custom = "Custom inspection"

    var id: String { rawValue }
}

enum Severity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"

    var id: String { rawValue }
}

enum IncidentKind: String, CaseIterable, Identifiable, Codable {
    case injury = "Injury"
    case nearMiss = "Near miss"
    case propertyDamage = "Property damage"
    case equipmentFailure = "Equipment failure"
    case safetyConcern = "Safety concern"
    case environmental = "Environmental"
    case other = "Other"

    var id: String { rawValue }
}

enum InjuryLevel: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case firstAid = "First aid"
    case medicalAttention = "Medical attention"
    case lostTime = "Lost time"
    case serious = "Serious"

    var id: String { rawValue }
}

enum AuditKind: String, CaseIterable, Identifiable, Codable {
    case safety = "Safety audit"
    case operational = "Operational audit"
    case compliance = "Compliance audit"
    case site = "Site audit"
    case equipment = "Equipment audit"

    var id: String { rawValue }
}

enum ReminderCategory: String, CaseIterable, Identifiable, Codable {
    case inspection = "Inspection due"
    case certificate = "Certificate expiry"
    case insurance = "Insurance renewal"
    case servicing = "Equipment servicing"
    case training = "Staff training renewal"
    case followUp = "Corrective action follow-up"

    var id: String { rawValue }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free = "Free"
    case pro = "Pro"
    case business = "Business"

    var id: String { rawValue }
}

