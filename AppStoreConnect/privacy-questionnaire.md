# App Privacy Draft

Apple requires a privacy policy URL for all apps. Review this draft with counsel and update it to match the shipping app and backend before submitting.

## Data Collection Summary

Current local-first build:

- Business profile data: collected in the app and stored locally on device.
- Inspection, incident, SOP, audit, reminder, and report data: collected in the app and stored locally on device.
- Photos: selected or captured by the user and stored locally for inspection/incident evidence.
- Audio: microphone input is used for speech-to-text notes. The app stores the resulting text note, not a persistent audio recording.
- Purchases: StoreKit/App Store handles subscription purchase data. The app reads entitlement status from StoreKit.
- Notifications: local reminders are scheduled on device.

Backend placeholder:

- The code includes a placeholder for a secure backend AI endpoint.
- Do not mark server-side collection as active until a real backend is deployed.
- If images, notes, or compliance records are sent to a backend later, update App Privacy, Privacy Policy, security controls, and retention language before release.

## Suggested App Privacy Labels For Current Build

Data linked to the user:

- Purchases: used for app functionality through StoreKit subscription entitlement checks.
- User Content: photos, notes, inspection records, incident records, SOPs, audits, reminders, and business profile details are created by the user for app functionality. Current build stores this data locally.

Data not linked to the user:

- Diagnostics: none unless analytics/crash reporting is added later.
- Usage Data: none unless analytics is added later.

Tracking:

- Does this app track users across apps and websites owned by other companies? No.

Third-party advertising:

- No.

Data used for advertising:

- No.

Data shared with data brokers:

- No.

Sensitive safety/compliance caution:

- The app may contain user-entered operational safety information. It should be treated as private business content and should not be used for advertising or sold to third parties.

## Required URL Fields

- Privacy Policy URL: `https://YOUR_DOMAIN.com/privacy`
- User Privacy Choices URL: optional unless you add account deletion/data export flows or backend data processing.

