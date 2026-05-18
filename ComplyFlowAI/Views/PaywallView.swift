import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Upgrade ComplyFlow AI")
                        .font(.title.bold())
                    Text("Subscriptions are handled with Apple StoreKit 2 and In-App Purchase.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                PlanCard(
                    name: "Free",
                    price: "£0",
                    summary: "For trying core workflows",
                    features: ["3 inspections/month", "1 SOP/month", "Basic reports", "ComplyFlow AI branding"],
                    productID: nil
                )

                PlanCard(
                    name: "Pro Monthly",
                    price: "£24.99",
                    summary: "For active operators",
                    features: ["Unlimited inspections", "Unlimited SOP generation", "Audit scoring", "AI corrective action plans", "PDF exports", "Compliance reminders"],
                    productID: .proMonthly
                )

                PlanCard(
                    name: "Pro Yearly",
                    price: "£199.99",
                    summary: "Best value for year-round compliance",
                    features: ["All Pro features", "Advanced reports", "Recurring compliance workflows", "Unlimited exports"],
                    productID: .proYearly
                )

                PlanCard(
                    name: "Business Monthly",
                    price: "£99.99",
                    summary: "For multi-site and team workflows",
                    features: ["Multi-site support", "Team management placeholder", "White-label branding", "Advanced audit tools", "Unlimited exports"],
                    productID: .businessMonthly
                )

                Button {
                    Task { await subscriptions.restorePurchases() }
                } label: {
                    Label("Restore purchases", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                HStack {
                    Link("Terms of Use", destination: ComplianceConstants.termsOfUseURL)
                    Spacer()
                    Link("Privacy Policy", destination: ComplianceConstants.privacyPolicyURL)
                }
                .font(.footnote)

                if subscriptions.isLoading {
                    ProgressView("Loading StoreKit products")
                }
                if let error = subscriptions.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                ComplianceDisclaimerView()
            }
            .padding()
        }
        .navigationTitle("Plans")
        .complyFlowScreenBackground()
        .task {
            await subscriptions.loadProducts()
        }
    }
}

private struct PlanCard: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    let name: String
    let price: String
    let summary: String
    let features: [String]
    let productID: SubscriptionManager.ProductID?

    private var product: Product? {
        productID.flatMap { subscriptions.product(for: $0) }
    }

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.title3.bold())
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(product?.displayPrice ?? price)
                        .font(.headline)
                }

                ForEach(features, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let product {
                    Button {
                        Task { await subscriptions.purchase(product) }
                    } label: {
                        Text(subscriptions.purchasedProductIDs.contains(product.id) ? "Current plan" : "Subscribe")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(subscriptions.purchasedProductIDs.contains(product.id))
                } else if productID != nil {
                    Text("Configure product ID in App Store Connect or StoreKit testing.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct TeamManagementView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if subscriptions.currentPlan == .business {
                    CardSurface {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Team workflows")
                                .font(.title3.bold())
                            Label("Multiple users placeholder", systemImage: "person.3")
                            Label("Roles placeholder: Owner, Supervisor, Field User", systemImage: "key")
                            Label("Assignment placeholder for inspections and tasks", systemImage: "arrow.triangle.branch")
                            Label("Multi-site access controls placeholder", systemImage: "building.2")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    UpgradeBanner(
                        title: "Business tier feature",
                        message: "Team management, multi-site workflows, and white-label branding are available on the Business plan.",
                        action: { showPaywall = true }
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Team Management")
        .complyFlowScreenBackground()
        .navigationDestination(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
