#!/usr/bin/env bash
# Builds a release APK (or app bundle) that is safe to publish.
#
# Flutter writes the project's absolute path into libapp.so (the address of
# dart_plugin_registrant.dart), --obfuscate or not, so a plain build gives away
# the home directory it was made in. This builds a copy of the project at a
# neutral path (Linux, needs bubblewrap), then checks the result.
#
# Usage: tool/build_release.sh [apk|appbundle]
# Result: build/release/mialuna-<version>.apk (or .aab), symbols in
# build/symbols. See docs/release.md.
set -euo pipefail

kind=${1:-apk}
case $kind in
  apk) output=app/outputs/flutter-apk/app-release.apk ext=apk ;;
  appbundle) output=app/outputs/bundle/release/app-release.aab ext=aab ;;
  *) echo "usage: $0 [apk|appbundle]" >&2; exit 2 ;;
esac

repo=$(cd "$(dirname "$0")/.." && pwd)
neutral=/mnt/mialuna
key="$repo/android/key.properties"

for tool in bwrap flutter python3 git; do
  command -v "$tool" >/dev/null || { echo "$tool is needed" >&2; exit 1; }
done
[ -f "$key" ] || {
  echo "android/key.properties is missing: this would not be a release" >&2
  exit 1
}

version=$(sed -n 's/^version: *\([^+]*\)+.*/\1/p' "$repo/pubspec.yaml")
work="$repo/build/release"
result="$work/mialuna-$version.$ext"
rm -rf "$work/src" "$result" "$work/unchecked.$ext"
mkdir -p "$work/src" "$repo/build/symbols"

if [ -n "$(git -C "$repo" status --porcelain)" ]; then
  echo "NOTE: there are uncommitted changes, and they are part of this build"
fi
# What git knows or would add: no build output, no secrets.
(cd "$repo" && git ls-files -z -co --exclude-standard |
  tar --null --ignore-failed-read -T - -cf -) | tar -xf - -C "$work/src"

# Only the project moves: the SDKs and the keystore are read where they are.
# No Gradle or Kotlin daemon, which would live outside this view of the disk.
bwrap --dev-bind / / --tmpfs /mnt --dir "$neutral" \
  --bind "$work/src" "$neutral" \
  --ro-bind "$key" "$neutral/android/key.properties" \
  --chdir "$neutral" \
  --setenv GRADLE_OPTS "-Dorg.gradle.daemon=false -Dkotlin.compiler.execution.strategy=in-process" \
  bash -c '"$1" pub get && "$1" build "$2" --release --obfuscate --split-debug-info=build/symbols' \
  _ "$(command -v flutter)" "$kind"

# The file gets its release name only once it has passed the check.
cp "$work/src/build/$output" "$work/unchecked.$ext"
python3 "$repo/tool/check_release.py" "$work/unchecked.$ext"
mv "$work/unchecked.$ext" "$result"
cp "$work/src/build/symbols/"* "$repo/build/symbols/"

echo
echo "Ready to publish: $result"
sha256sum "$result" | cut -d' ' -f1
