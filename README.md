# ComplyFlow AI

ComplyFlow AI is a SwiftUI iOS app scaffold for operational compliance, inspections, SOPs, audits, incidents, corrective actions, reminders, PDF exports, and subscription-gated Pro/Business workflows.

## Open in Xcode

Open `ComplyFlowAI.xcodeproj`, select the `ComplyFlowAI` scheme, choose an iOS 17+ simulator, and run.

## Notes

- Mock AI is enabled by default through `MockAIService`.
- `RemoteAIService` contains the backend placeholder endpoint and does not store API keys in the app.
- StoreKit 2 product IDs are scaffolded in `SubscriptionManager`:
  - `com.complyflowai.pro.monthly`
  - `com.complyflowai.pro.yearly`
  - `com.complyflowai.business.monthly`
- Configure matching products in App Store Connect or a StoreKit configuration file before testing purchases.
- PDF exports, reminders, camera/photo upload, speech notes, local SwiftData storage, and native share sheet support are included.

