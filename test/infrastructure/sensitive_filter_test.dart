import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/security/sensitive_filter.dart';

void main() {
  group('SensitiveFilter Tests', () {
    test('Scrubs Gemini API Key from string', () {
      const log =
          'Failed request with key AIzaSyA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6';
      final scrubbed = SensitiveFilter.scrub(log);
      expect(scrubbed, contains('[REDACTED]'));
      expect(
        scrubbed,
        isNot(contains('AIzaSyA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6')),
      );
    });

    test('Scrubs Header values', () {
      const header = 'x-goog-api-key: secret_key_12345';
      final scrubbed = SensitiveFilter.scrub(header);
      expect(scrubbed, equals('x-goog-api-key: [REDACTED]'));
    });

    test('Scrubs the whole Authorization header value', () {
      const header = 'Authorization: DeepL-Auth-Key secret_deepl_token_here';
      final scrubbed = SensitiveFilter.scrub(header);
      expect(scrubbed, equals('Authorization: [REDACTED]'));
      expect(scrubbed, isNot(contains('secret_deepl_token_here')));
    });

    test('Scrubs Bearer tokens and generic api_key / secret labels', () {
      expect(
        SensitiveFilter.scrub('Bearer abc.def.ghi'),
        equals('Bearer [REDACTED]'),
      );
      expect(
        SensitiveFilter.scrub('api_key=abcdef123456'),
        equals('api_key=[REDACTED]'),
      );
      expect(
        SensitiveFilter.scrub('client secret: hunter2'),
        equals('client secret: [REDACTED]'),
      );
      expect(
        SensitiveFilter.scrub('X-NCP-APIGW-API-KEY: ncp_secret_value'),
        equals('X-NCP-APIGW-API-KEY: [REDACTED]'),
      );
    });

    test('Scrubs a DeepL key but leaves plain UUID row ids intact', () {
      const deeplKey = '12345678-1234-1234-1234-123456789abc:fx';
      expect(SensitiveFilter.scrub('key=$deeplKey'), isNot(contains(deeplKey)));

      // Row ids are uuid v4 and appear in ordinary diagnostics. Redacting them
      // would make logs useless.
      const rowId = 'namespace 12345678-1234-1234-1234-123456789abc scanned';
      expect(SensitiveFilter.scrub(rowId), equals(rowId));
    });

    test('Shortens the user home directory to %USERPROFILE%', () {
      expect(
        SensitiveFilter.scrub(r'C:\Users\kingh\AppData\Roaming\LangForge'),
        equals(r'%USERPROFILE%\AppData\Roaming\LangForge'),
      );
      expect(
        SensitiveFilter.scrub('/home/kingh/projects/langforge'),
        equals('%USERPROFILE%/projects/langforge'),
      );
    });

    test('Is idempotent', () {
      const raw = 'Authorization: Bearer abc123 at C:\\Users\\kingh\\logs';
      final once = SensitiveFilter.scrub(raw);
      expect(SensitiveFilter.scrub(once), equals(once));
    });
  });
}
