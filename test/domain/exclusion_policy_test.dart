import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/policy/exclusion_policy.dart';

void main() {
  group('ExclusionPolicy Tests', () {
    test('Excludes URLs', () {
      expect(ExclusionPolicy.shouldExclude('https://minecraft.net'), isTrue);
      expect(ExclusionPolicy.shouldExclude('http://example.com/api'), isTrue);
    });

    test('Excludes Minecraft resource IDs', () {
      expect(ExclusionPolicy.shouldExclude('minecraft:stone'), isTrue);
      expect(ExclusionPolicy.shouldExclude('quark:oak_hedge'), isTrue);
    });

    test('Excludes commands, paths, UUIDs, numerics, and empty strings', () {
      expect(ExclusionPolicy.shouldExclude('/give @p diamond'), isTrue);
      expect(ExclusionPolicy.shouldExclude(r'C:\Games\Minecraft'), isTrue);
      expect(
        ExclusionPolicy.shouldExclude('550e8400-e29b-41d4-a716-446655440000'),
        isTrue,
      );
      expect(ExclusionPolicy.shouldExclude('1.20.1'), isTrue);
      expect(ExclusionPolicy.shouldExclude(''), isTrue);
    });

    test('Excludes token-only strings', () {
      expect(ExclusionPolicy.shouldExclude('%s %d'), isTrue);
      expect(ExclusionPolicy.shouldExclude('§a§r'), isTrue);
    });

    test('Does not exclude translatable natural language text', () {
      expect(ExclusionPolicy.shouldExclude('Oak Hedge'), isFalse);
      expect(ExclusionPolicy.shouldExclude('Ancient Tome'), isFalse);
      expect(ExclusionPolicy.shouldExclude('Welcome, %s!'), isFalse);
    });
  });
}
