# GitHub TestFlight Upload

The `TestFlight Upload` workflow builds a signed archive, exports an App Store Connect IPA, and uploads it to the ComplyFlow AI app record.

Run it from GitHub Actions with a new build number after these repository secrets are configured:

- `APPLE_TEAM_ID`: Apple Developer Team ID, not the App Store Connect URL team UUID.
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: Base64 encoded Apple Distribution `.p12` certificate.
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`: Password for the `.p12` certificate.
- `IOS_APP_STORE_PROFILE_BASE64`: Base64 encoded App Store provisioning profile for `com.complyflowai.app`.
- `TEMP_KEYCHAIN_PASSWORD`: Random password used only for the temporary CI keychain.
- `APP_STORE_CONNECT_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_ISSUER_ID`: App Store Connect API issuer ID.
- `APP_STORE_CONNECT_PRIVATE_KEY`: Contents of the downloaded `AuthKey_XXXXXXXXXX.p8` private key.

Useful macOS commands for creating the base64 secrets:

```bash
base64 -i ios_distribution.p12 | pbcopy
base64 -i ComplyFlowAI_AppStore.mobileprovision | pbcopy
```

Use a Team API key from App Store Connect `Users and Access > Integrations > App Store Connect API`. Store the `.p8` key securely because Apple only lets you download it once.

After a successful workflow run, App Store Connect can take several minutes to process the uploaded build before it appears in the version `Build` picker.
