import SwiftData
import SwiftUI

struct BusinessProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    var body: some View {
        Group {
            if let profile = profiles.first {
                BusinessProfileForm(profile: profile)
            } else {
                VStack(spacing: 16) {
                    EmptyStateView(title: "No business profile", message: "Create a profile to personalize reports, SOPs, reminders, and audit summaries.", systemImage: "building.2")
                    Button("Create profile") {
                        modelContext.insert(BusinessProfile(businessName: "My Business"))
                        try? modelContext.save()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationTitle("Business Profile")
        .complyFlowScreenBackground()
    }
}

private struct BusinessProfileForm: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: BusinessProfile
    @State private var locationsText = ""

    var body: some View {
        Form {
            Section("Business") {
                TextField("Business name", text: $profile.businessName)
                Picker("Industry", selection: industryBinding) {
                    ForEach(Industry.allCases) { industry in
                        Text(industry.rawValue).tag(industry)
                    }
                }
                Picker("Team size", selection: teamSizeBinding) {
                    ForEach(BusinessSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
            }

            Section("Locations") {
                TextEditor(text: $locationsText)
                    .frame(minHeight: 90)
                    .onChange(of: locationsText) { _, newValue in
                        profile.locations = newValue
                            .split(whereSeparator: \.isNewline)
                            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                    }
            }

            Section("Expiry dates") {
                DatePicker("Insurance renewal", selection: insuranceDateBinding, displayedComponents: .date)
                DatePicker("Certification renewal", selection: certificationDateBinding, displayedComponents: .date)
            }

            Section("Safety notes") {
                TextEditor(text: $profile.safetyNotes)
                    .frame(minHeight: 120)
                VoiceNoteButton(text: $profile.safetyNotes)
            }

            Section {
                NavigationLink(value: AppRoute.team) {
                    Label("Team management", systemImage: "person.3")
                }
                Button("Save profile") {
                    try? modelContext.save()
                }
            }
        }
        .onAppear {
            locationsText = profile.locations.joined(separator: "\n")
        }
    }

    private var industryBinding: Binding<Industry> {
        Binding {
            Industry(rawValue: profile.industry) ?? .construction
        } set: {
            profile.industry = $0.rawValue
        }
    }

    private var teamSizeBinding: Binding<BusinessSize> {
        Binding {
            BusinessSize(rawValue: profile.teamSize) ?? .smallTeam
        } set: {
            profile.teamSize = $0.rawValue
        }
    }

    private var insuranceDateBinding: Binding<Date> {
        Binding {
            profile.insuranceExpiryDates.first ?? .now
        } set: {
            profile.insuranceExpiryDates = [$0]
        }
    }

    private var certificationDateBinding: Binding<Date> {
        Binding {
            profile.certificationExpiryDates.first ?? .now
        } set: {
            profile.certificationExpiryDates = [$0]
        }
    }
}

