# Xcode Cloud via GitHub

The repository is ready for Xcode Cloud at:

https://github.com/lanray07/ComplyFlow-AI

App Store Connect currently shows that the first Xcode Cloud workflow must be created from Xcode.

## Finish Setup On A Mac

1. Open Xcode.
2. Clone `https://github.com/lanray07/ComplyFlow-AI.git`.
3. Open `ComplyFlowAI.xcodeproj`.
4. Select the `ComplyFlowAI` target.
5. Set the Apple Developer team for signing.
6. Confirm the bundle identifier is `com.complyflowai.app`.
7. Choose Product > Xcode Cloud > Create Workflow.
8. Select the GitHub repository `lanray07/ComplyFlow-AI`.
9. Use branch `main`.
10. Use the shared scheme `ComplyFlowAI`.
11. Configure the workflow to archive for TestFlight/App Store distribution.

## GitHub CI

The repository includes `.github/workflows/xcode-build.yml`, which builds the app on a macOS GitHub Actions runner with code signing disabled. This validates the SwiftUI project structure without requiring signing certificates.

App Store/TestFlight uploads still require Apple signing through Xcode Cloud or manually configured GitHub Actions secrets.
