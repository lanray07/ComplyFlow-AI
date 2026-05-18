import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var businessName = ""
    @Published var selectedIndustry: Industry = .construction
    @Published var selectedBusinessSize: BusinessSize = .smallTeam
    @Published var acceptedDisclaimer = false

    var canContinue: Bool {
        acceptedDisclaimer && !businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeBusinessProfile() -> BusinessProfile {
        BusinessProfile(
            businessName: businessName.trimmingCharacters(in: .whitespacesAndNewlines),
            industry: selectedIndustry.rawValue,
            teamSize: selectedBusinessSize.rawValue,
            locations: [],
            safetyNotes: "AI suggestions must be reviewed before operational use."
        )
    }
}

