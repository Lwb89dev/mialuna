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

3. Wire it into `android/app/build.gradle.kts`: load the `key.properties`
   file and use a `signingConfigs { release { ... } }` block instead of the
   debug signature. See the official guide:
   https://docs.flutter.dev/deployment/android#signing-the-app

4. Build:

   ```bash
   flutter build appbundle --release   # Play Store
   flutter build apk --release         # direct distribution / F-Droid
   ```

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
