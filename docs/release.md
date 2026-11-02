# Build and release

## Development

```bash
mise install          # Flutter 3.47.9 + JDK 21
flutter pub get
flutter run           # with a device/emulator attached
```

## Verification

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Android — debug

```bash
flutter build apk --debug
```

## Android — release

1. Generate a keystore (once, keep it safe):

   ```bash
   keytool -genkey -v -keystore ~/mialuna-upload-key.jks \
     -keyalg RSA -keysize 4096 -validity 10000 -alias mialuna
   ```

2. Create `android/key.properties` (never commit it):

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=mialuna
   storeFile=/absolute/path/mialuna-upload-key.jks
   ```

3. `android/app/build.gradle.kts` already reads `android/key.properties` and
   signs the release build with it. Without the file the release build is
   signed with the debug key and Gradle warns: fine to try an APK, never to
   publish one.

4. Build (code shrinking with R8 is on; keep the symbols to read crashes):

   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
   flutter build apk --release --obfuscate --split-debug-info=build/symbols
   ```

   The debug build installs next to the release one (`app.mialuna.social.debug`,
   labelled "Mialuna Debug") and, unlike release, may talk plain HTTP to
   `localhost`, `127.0.0.1` and `10.0.2.2` and trusts user-installed CAs — for
   running against a local relay.

   For store screenshots, `--dart-define=MIALUNA_SECURE_SCREENS=false` turns
   off the screenshot block on private screens (never ship a build made so).

## F-Droid / IzzyOnDroid

Store metadata lives in `fastlane/metadata/android/`. Requirements already
met: no proprietary dependencies, no Google Play Services, MIT license,
icons and descriptions included. Publication happens through an RFP at
https://gitlab.com/fdroid/rfd or a request to IzzyOnDroid.

## iOS

Requires macOS with Xcode. Once available:

```bash
flutter build ios --release
```

iOS compilation has not been verified on a real environment yet.

### Native code added in 0.13.0 that is only verified on Android

- `ios/Runner/AppDelegate.swift` registers the `app.mialuna.social/media`
  channel (video cover extraction with `AVAssetImageGenerator`). It mirrors
  `android/.../MediaBridge.kt` but has **never been compiled**: build it on a
  Mac first. If it fails, the app still works — posters simply fall back to
  a dark placeholder and new videos publish without a cover.
- Amber (NIP-55) is Android-only; on iOS use a NIP-46 bunker or a local key.
  Private messages work with both (NIP-44 goes through the bunker).
