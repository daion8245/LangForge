import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/export/pack_meta_builder.dart';

/// The shipped data file, not a copy. A test against a mock would pass even if
/// the real table were wrong (ROADMAP Phase 5 완료 조건).
String readShippedVersions() =>
    File('assets/data/mc_versions.json').readAsStringSync();

void main() {
  group('PackMetaBuilder', () {
    // From the Minecraft resource pack format history, mirrored in
    // TECHNICAL.md 3.6.
    const expectedFormats = <String, int>{
      '1.21.4': 46,
      '1.21.3': 42,
      '1.21.2': 42,
      '1.21.1': 34,
      '1.21': 34,
      '1.20.6': 32,
      '1.20.4': 22,
      '1.20.2': 18,
      '1.20.1': 15,
      '1.19.4': 13,
      '1.19.2': 9,
      '1.18.2': 8,
    };

    test('The shipped table lists exactly the 12 supported versions', () {
      final versions = PackMetaBuilder.parseVersions(readShippedVersions());
      expect(versions.length, equals(expectedFormats.length));
      expect(
        versions.map((v) => v.version).toSet(),
        equals(expectedFormats.keys.toSet()),
      );
    });

    test('Every one of the 12 versions resolves to the right pack_format', () {
      final data = readShippedVersions();
      expectedFormats.forEach((version, packFormat) {
        expect(
          PackMetaBuilder.getPackFormat(data, version),
          equals(packFormat),
          reason: 'pack_format for Minecraft $version',
        );
      });
    });

    test('An unlisted version is an error, never a guess', () {
      // Shipping a guessed pack_format produces a pack Minecraft silently
      // refuses to load, so this must not fall back to a constant.
      expect(
        () => PackMetaBuilder.getPackFormat(readShippedVersions(), '1.99.99'),
        throwsA(isA<UnknownMinecraftVersion>()),
      );
    });

    test('pack.mcmeta has the structure Minecraft expects', () {
      final jsonStr = PackMetaBuilder.buildPackMeta(packFormat: 15);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final pack = decoded['pack'] as Map<String, dynamic>;

      expect(pack['pack_format'], equals(15));
      expect(pack['description'], contains('LangForge'));
      expect(jsonStr.endsWith('\n'), isTrue);
    });
  });
}
