import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('media pickers and camera have their required privacy descriptions', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    for (final key in [
      'NSPhotoLibraryUsageDescription',
      'NSCameraUsageDescription',
      'NSMicrophoneUsageDescription',
    ]) {
      expect(plist, contains('<key>$key</key>'), reason: key);
    }
  });
}
