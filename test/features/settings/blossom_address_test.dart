import 'package:flutter_test/flutter_test.dart';
import 'package:mialuna/features/settings/settings_controller.dart';

/// A Blossom server must be reachable over https, and the field says so when
/// it is not (typing http://… used to empty it without a word).
void main() {
  test('https is added when missing, slashes go', () {
    expect(
      SettingsController.cleanBlossomUrl('blossom.example.com'),
      'https://blossom.example.com',
    );
    expect(
      SettingsController.cleanBlossomUrl('  https://blossom.example.com// '),
      'https://blossom.example.com',
    );
  });

  test('anything that is not https is refused', () {
    for (final bad in [
      'http://127.0.0.1:4000',
      'http://blossom.example.com',
      'ftp://blossom.example.com',
      'wss://relay.example.com',
      '',
      '   ',
      'https://',
    ]) {
      expect(SettingsController.cleanBlossomUrl(bad), isNull, reason: bad);
    }
  });
}
