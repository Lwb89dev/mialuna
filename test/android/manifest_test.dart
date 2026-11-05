import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// What the Android app is allowed to be. These are decisions, not accidents:
/// a change here should be made on purpose, in a pull request that says why.
void main() {
  late String manifest;
  late String debugManifest;

  setUpAll(() {
    manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    debugManifest = File('android/app/src/debug/AndroidManifest.xml')
        .readAsStringSync();
  });

  test('asks for exactly the permissions it uses', () {
    final permissions = RegExp(r'uses-permission android:name="([^"]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1)!)
        .toSet();
    expect(permissions, {
      'android.permission.INTERNET',
      'android.permission.POST_NOTIFICATIONS',
    });
  });

  test('nothing is backed up, and nothing is sent in the clear', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    expect(manifest, isNot(contains('android:debuggable')));
    final config = File(
      'android/app/src/main/res/xml/network_security_config.xml',
    ).readAsStringSync();
    expect(config, contains('cleartextTrafficPermitted="false"'));
    expect(
      config,
      isNot(contains('src="user"')),
      reason: 'only the system\'s CAs',
    );
    expect(config, isNot(contains('<domain-config')));
  });

  test('the backup rules exclude everything, for cloud and for transfer', () {
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();
    for (final domain in [
      'root',
      'file',
      'database',
      'sharedpref',
      'external',
    ]) {
      expect(
        RegExp('<exclude domain="$domain"').allMatches(rules).length,
        2,
        reason: '$domain: cloud-backup and device-transfer',
      );
    }
  });

  test('only the launcher activity is reachable from outside', () {
    expect(RegExp('android:exported="true"').allMatches(manifest).length, 1);
    expect(RegExp('<activity').allMatches(manifest).length, 1);
    expect(RegExp('<service|<receiver|<provider').hasMatch(manifest), false);
    // One intent filter: MAIN / LAUNCHER. No deep links, no share targets.
    expect(RegExp('<intent-filter').allMatches(manifest).length, 1);
    expect(manifest, contains('android.intent.action.MAIN'));
    expect(
      manifest,
      isNot(
        contains(
          'android.intent.action.VIEW"/>\n            <category android:name="android.intent.category.BROWSABLE',
        ),
      ),
    );
    expect(manifest, contains('android:taskAffinity=""'));
  });

  test('only a debug build may talk to a local relay in the clear', () {
    final debugConfig = File(
      'android/app/src/debug/res/xml/network_security_config.xml',
    ).readAsStringSync();
    expect(debugConfig, contains('10.0.2.2'));
    expect(debugManifest, isNot(contains('usesCleartextTraffic="true"')));
    final release = File('android/app/build.gradle.kts').readAsStringSync();
    expect(release, contains('isMinifyEnabled = true'));
    expect(release, contains('key.properties'));
  });
}
