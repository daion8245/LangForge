import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/project/project_settings.dart';

void main() {
  group('ProjectToggles', () {
    test('defaults match TECHNICAL.md 3.4', () {
      const toggles = ProjectToggles.defaults;
      expect(toggles.autoSave, isTrue);
      expect(toggles.verboseLog, isFalse);
      expect(toggles.notifyOnComplete, isTrue);
      expect(toggles.keepOnRescan, isTrue);
      expect(toggles.allowSkipChecks, isFalse);
    });

    test('missing keys use defaults', () {
      final toggles = ProjectToggles.fromJsonString('{"verboseLog": true}');
      expect(toggles.verboseLog, isTrue);
      expect(toggles.autoSave, isTrue);
      expect(toggles.allowSkipChecks, isFalse);
    });

    test('unknown keys survive a round-trip', () {
      final toggles = ProjectToggles.fromJsonString(
        '{"autoSave": false, "futureFlag": 7, "nested": {"a": 1}}',
      );
      expect(toggles.autoSave, isFalse);
      expect(toggles.unknown['futureFlag'], 7);
      final encoded = toggles.toJsonString();
      expect(encoded, contains('futureFlag'));
      expect(encoded, contains('nested'));
      final again = ProjectToggles.fromJsonString(encoded);
      expect(again.unknown['futureFlag'], 7);
      expect(again.autoSave, isFalse);
    });

    test('corrupt JSON falls back to defaults', () {
      expect(ProjectToggles.fromJsonString('{'), ProjectToggles.defaults);
      expect(ProjectToggles.fromJsonString('[]'), ProjectToggles.defaults);
    });
  });
}
