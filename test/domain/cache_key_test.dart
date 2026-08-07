import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/cache/cache_key.dart';
import 'package:langforge/domain/cache/glossary_fingerprint_input.dart';

void main() {
  group('CacheKey', () {
    const base = CacheKey(
      sourceHash: 'hash-a',
      sourceLangCode: 'en_us',
      targetLangCode: 'ko_kr',
      providerId: 'gemini',
      modelId: 'gemini-2.0-flash',
      glossaryFingerprint: 'fp-1',
      protectorVersion: '1',
      postProcessorVersion: '1',
    );

    test('equal keys compare equal', () {
      expect(base, equals(base.copyWith()));
    });

    test('each of the 8 elements alone causes inequality', () {
      final mutants = <CacheKey>[
        base.copyWith(sourceHash: 'hash-b'),
        base.copyWith(sourceLangCode: 'ja_jp'),
        base.copyWith(targetLangCode: 'zh_cn'),
        base.copyWith(providerId: 'deepl'),
        base.copyWith(modelId: ''),
        base.copyWith(glossaryFingerprint: 'fp-2'),
        base.copyWith(protectorVersion: '2'),
        base.copyWith(postProcessorVersion: '2'),
      ];
      expect(mutants.toSet().length, equals(8));
      for (final mutant in mutants) {
        expect(mutant, isNot(equals(base)));
      }
    });
  });

  group('GlossaryFingerprintInput', () {
    test('sorts by source, target, namespace, caseSensitive', () {
      final inputs = [
        const GlossaryFingerprintInput(
          sourceTerm: 'B',
          targetTerm: '비',
          caseSensitive: false,
        ),
        const GlossaryFingerprintInput(
          sourceTerm: 'A',
          targetTerm: '에이',
          namespace: 'quark',
          caseSensitive: true,
        ),
        const GlossaryFingerprintInput(
          sourceTerm: 'A',
          targetTerm: '에이',
          caseSensitive: false,
        ),
      ]..sort();

      expect(inputs[0].sourceTerm, 'A');
      expect(inputs[0].namespace, isNull);
      expect(inputs[1].namespace, 'quark');
      expect(inputs[2].sourceTerm, 'B');
    });
  });
}
