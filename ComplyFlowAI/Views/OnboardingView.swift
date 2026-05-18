import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to ComplyFlow AI")
                            .font(.largeTitle.bold())
                        Text("Operational compliance, inspections, SOPs, incidents, audits, and recurring safety checks in one field-ready app.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    CardSurface {
                        VStack(alignment: .leading, spacing: 14) {
                            TextField("Business name", text: $viewModel.businessName)
                                .textContentType(.organizationName)

                            Picker("Industry", selection: $viewModel.selectedIndustry) {
                                ForEach(Industry.allCases) { industry in
                                    Text(industry.rawValue).tag(industry)
                                }
                            }

                            Picker("Business size", selection: $viewModel.selectedBusinessSize) {
                                ForEach(BusinessSize.allCases) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                        }
                    }

                    ComplianceDisclaimerView()

                    Toggle("I understand these safety and compliance disclaimers.", isOn: $viewModel.acceptedDisclaimer)
                        .font(.subheadline.weight(.medium))

                    Button {
                        completeOnboarding()
                    } label: {
                        Label("Create business profile", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!viewModel.canContinue)
                }
                .padding()
            }
            .navigationTitle("Setup")
            .complyFlowScreenBackground()
        }
    }

    private func completeOnboarding() {
        modelContext.insert(viewModel.makeBusinessProfile())
        modelContext.insert(SubscriptionState())
        try? modelContext.save()
        hasCompletedOnboarding = true
    }
}

