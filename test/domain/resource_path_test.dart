import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/normalize/resource_path.dart';

void main() {
  group('ResourcePathParser Tests', () {
    test('Identifies valid Minecraft lang resource paths', () {
      expect(
        ResourcePathParser.isLangResource('assets/quark/lang/en_us.json'),
        isTrue,
      );
      expect(
        ResourcePathParser.isLangResource('assets/exbeta/lang/ko_kr.json'),
        isTrue,
      );
      expect(
        ResourcePathParser.isLangResource(r'assets\emi\lang\ja_jp.json'),
        isTrue,
      );
    });

    test('Rejects non-lang resource paths', () {
      expect(
        ResourcePathParser.isLangResource('assets/quark/textures/item.png'),
        isFalse,
      );
      expect(
        ResourcePathParser.isLangResource('assets/quark/lang/sub/en_us.json'),
        isFalse,
      );
      expect(
        ResourcePathParser.isLangResource('assets/quark/en_us.json'),
        isFalse,
      );
      expect(ResourcePathParser.isLangResource('pack.mcmeta'), isFalse);
    });

    test('Parses namespace and rawCode correctly', () {
      final info = ResourcePathParser.parse('assets/Quark/lang/en_US.json');
      expect(info, isNotNull);
      expect(info!.namespace, equals('quark'));
      expect(info.rawCode, equals('en_US'));
      expect(info.hasUppercaseNamespace, isTrue);
    });

    test('entryPath keeps the archive spelling so extraction can find it', () {
      // Rebuilding the path from the lowercased namespace would address an
      // entry that does not exist in the archive (TECHNICAL.md 4.5).
      final info = ResourcePathParser.parse('assets/Quark/lang/en_US.json');
      expect(info!.entryPath, equals('assets/Quark/lang/en_US.json'));
    });

    test('Backslash paths are normalised to forward slashes', () {
      final info = ResourcePathParser.parse(r'assets\Emi\lang\ja_JP.json');
      expect(info!.entryPath, equals('assets/Emi/lang/ja_JP.json'));
      expect(info.namespace, equals('emi'));
    });
  });
}
