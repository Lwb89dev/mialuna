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

4. Build with the release script (Linux, needs `bubblewrap`), never with a
   plain `flutter build`:

   ```bash
   tool/build_release.sh            # build/release/mialuna-<version>.apk
   tool/build_release.sh appbundle  # the same, as an .aab
   ```

   Flutter writes the project's absolute path into the app, `--obfuscate` or
   not, which would publish the builder's home directory. The script builds a
   copy of the project as `/mnt/mialuna`, then runs `tool/check_release.py`,
   which refuses a package holding another project path, your home directory or
   user name, or a word listed in `tool/private_words.txt` (one per line, not
   committed). Publish only the file it names. As a safety net, Gradle stops a
   release signed with the real key from a path that names you;
   `MIALUNA_LOCAL_RELEASE=1 flutter run --release` is for builds that stay on
   your machine.

   Code shrinking with R8 is on; keep `build/symbols` to read crashes.

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
