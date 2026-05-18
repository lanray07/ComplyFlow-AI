# StoreKit 2 Subscription Setup Draft

Create these products in App Store Connect under a single subscription group so users maintain one active subscription level.

## Subscription Group

- Reference name: ComplyFlow AI Plans
- Subscription group display name: ComplyFlow AI

## Product 1

- Product ID: `com.complyflowai.pro.monthly`
- Reference name: Pro Monthly
- Display name: ComplyFlow AI Pro Monthly
- Duration: 1 month
- Price placeholder: GBP 24.99
- Description: Unlimited inspections, unlimited SOP generation, audit scoring, advanced reports, PDF exports, reminders, and AI corrective action plans.

## Product 2

- Product ID: `com.complyflowai.pro.yearly`
- Reference name: Pro Yearly
- Display name: ComplyFlow AI Pro Yearly
- Duration: 1 year
- Price placeholder: GBP 199.99
- Description: Year-round access to Pro features, including unlimited inspections, unlimited SOP generation, audit scoring, advanced reports, PDF exports, reminders, and AI corrective action plans.

## Product 3

- Product ID: `com.complyflowai.business.monthly`
- Reference name: Business Monthly
- Display name: ComplyFlow AI Business Monthly
- Duration: 1 month
- Price placeholder: GBP 99.99
- Description: Business features for multi-site workflows, team management placeholders, white-label branding placeholders, advanced audit tools, and unlimited exports.

## App Review Notes For Subscriptions

The app uses StoreKit 2 to load products, purchase subscriptions, restore purchases, and read current entitlements. PDF export, audit scoring, AI corrective action plans, unlimited inspections, and unlimited SOP generation are subscription-gated.

Mock AI mode is enabled by default for review. No API key is required.

## Screenshot Requirements

Upload subscription review screenshots showing:

- Paywall with plan names and pricing
- Pro feature gate such as PDF export
- Subscription status shown in the dashboard

