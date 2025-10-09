# Android release signing (Play upload)

To upload to Google Play (internal test/closed/open/production), use a proper upload keystore instead of debug signing.

## 1) Generate an upload keystore (one-time)

Run in a terminal (Windows cmd):

```
keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Remember the passwords you enter. Keep the file private.

## 2) Create `key.properties`

Create `android/key.properties` with:

```
storeFile=C:\\Users\\<YOUR_USERNAME>\\upload-keystore.jks
storePassword=<your-store-password>
keyAlias=upload
keyPassword=<your-key-password>
```

- `key.properties` is already in `.gitignore`.
- Use double backslashes in Windows paths or keep it next to project and use a relative path.

## 3) Build signed artifacts

- App Bundle (recommended for Play):
```
flutter build appbundle --release
```
- APKs per-ABI (optional smaller APKs):
```
flutter build apk --release --split-per-abi
```

The build will use `signingConfigs.release` automatically if `key.properties` exists, otherwise it falls back to the debug key for local runs.

## 4) Upload to Play Console

- Internal testing → Create new release → Upload the AAB found at:
  - `build/app/outputs/bundle/release/app-release.aab`
- Add Release name (e.g. 1.0.0+1), release notes, countries/testers, and roll out.

## Notes
- Keep your keystore and passwords safe. Losing them means you cannot update the app under the same signature.
- Back up the keystore to a secure location (encrypted cloud/password manager).
