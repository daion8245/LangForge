import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/validation/json_precheck.dart';

void main() {
  group('JsonPrecheck Tests', () {
    test('Validates normal key-value JSON string', () {
      const jsonStr = '''
{
  "block.quark.oak_hedge": "Oak Hedge",
  "item.quark.tome": "Ancient Tome"
}
''';
      final result = JsonPrecheck.check(jsonStr);
      expect(result.isValid, isTrue);
      expect(result.entries.length, equals(2));
      expect(
        result.keyOrder,
        equals(['block.quark.oak_hedge', 'item.quark.tome']),
      );
    });

    test('Detects JSON syntax errors with line number', () {
      const brokenJsonStr = '''
{
  "item.exbroken.valid": "Valid Item"
  "item.exbroken.broken": "Broken Item"
}
''';
      final result = JsonPrecheck.check(brokenJsonStr);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Syntax error'));
      expect(result.errorLine, isNotNull);
    });

    test('Rejects non-string values', () {
      const invalidValueJson = '''
{
  "key1": "valid",
  "key2": 123
}
''';
      final result = JsonPrecheck.check(invalidValueJson);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('non-string value'));
    });
  });

  group('JsonPrecheck duplicate key detection', () {
    // jsonDecode keeps only the last value for a repeated key, so a check that
    // inspects the decoded map can never see the duplicate. The raw text is
    // the only evidence it existed.
    test('Reports a key that appears twice', () {
      const jsonStr = '''
{
  "item.a": "First",
  "item.b": "Other",
  "item.a": "Second"
}
''';
      final result = JsonPrecheck.check(jsonStr);
      expect(result.isValid, isTrue);
      expect(result.duplicateKeys, equals(['item.a']));
    });

    test('Reports each duplicated key once', () {
      const jsonStr = '''
{
  "a": "1",
  "a": "2",
  "a": "3",
  "b": "1",
  "b": "2"
}
''';
      expect(JsonPrecheck.check(jsonStr).duplicateKeys, equals(['a', 'b']));
    });

    test('Clean input reports nothing', () {
      const jsonStr = '{"a": "1", "b": "2", "c": "3"}';
      expect(JsonPrecheck.check(jsonStr).duplicateKeys, isEmpty);
    });

    test('A value that looks like a key is not counted', () {
      // The colon and braces live inside a string, so they must not be read as
      // structure.
      const jsonStr = '{"a": "b\\": \\"c", "d": "plain"}';
      final result = JsonPrecheck.check(jsonStr);
      expect(result.isValid, isTrue);
      expect(result.duplicateKeys, isEmpty);
    });

    test('Escaped quotes in a key are handled', () {
      const jsonStr = r'{"say \"hi\"": "1", "say \"hi\"": "2"}';
      expect(JsonPrecheck.check(jsonStr).duplicateKeys, equals([r'say "hi"']));
    });
  });
}
