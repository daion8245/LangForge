import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/cache/cache_key.dart';
import 'package:langforge/domain/cache/cache_kind.dart';
import 'package:langforge/domain/cache/glossary_fingerprint_input.dart';
import 'package:langforge/infrastructure/cache/cache_hashes.dart';
import 'package:langforge/infrastructure/cache/translation_cache_store.dart';

void main() {
  late TranslationCacheStore store;

  setUp(() {
    store = TranslationCacheStore.inMemory();
  });

  tearDown(() async {
    await store.close();
  });

  CacheKeyFixture key({
    String source = 'Copper Ingot',
    String sourceLang = 'en_us',
    String targetLang = 'ko_kr',
    String provider = 'gemini',
    String model = 'gemini-2.0-flash',
    String? fingerprint,
  }) {
    return CacheKeyFixture(
      source: source,
      key: TranslationCacheStore.buildKey(
        sourceText: source,
        sourceLangCode: sourceLang,
        targetLangCode: targetLang,
        providerId: provider,
        modelId: model,
        glossaryFingerprint:
            fingerprint ?? CacheHashes.glossaryFingerprint(const []),
      ),
    );
  }

  test('same source and conditions hit without needing another put', () async {
    final fixture = key();
    await store.put(
      key: fixture.key,
      kind: CacheKind.auto,
      translation: '구리 주괴',
      sourceText: fixture.source,
    );

    final hit = await store.lookup(fixture.key);
    expect(hit, isNotNull);
    expect(hit!.kind, CacheKind.auto);
    expect(hit.translation, '구리 주괴');
  });

  test('changing any of the 8 key elements misses', () async {
    final fixture = key();
    await store.put(
      key: fixture.key,
      kind: CacheKind.auto,
      translation: '구리 주괴',
      sourceText: fixture.source,
    );

    final emptyFp = CacheHashes.glossaryFingerprint(const []);
    final otherFp = CacheHashes.glossaryFingerprint([
      const GlossaryFingerprintInput(
        sourceTerm: 'Copper',
        targetTerm: '구리',
        caseSensitive: false,
      ),
    ]);

    final missKeys = [
      TranslationCacheStore.buildKey(
        sourceText: 'Iron Ingot',
        sourceLangCode: 'en_us',
        targetLangCode: 'ko_kr',
        providerId: 'gemini',
        modelId: 'gemini-2.0-flash',
        glossaryFingerprint: emptyFp,
      ),
      fixture.key.copyWith(sourceLangCode: 'ja_jp'),
      fixture.key.copyWith(targetLangCode: 'zh_cn'),
      fixture.key.copyWith(providerId: 'deepl'),
      fixture.key.copyWith(modelId: ''),
      fixture.key.copyWith(glossaryFingerprint: otherFp),
      fixture.key.copyWith(protectorVersion: '999'),
      fixture.key.copyWith(postProcessorVersion: '999'),
    ];

    for (final miss in missKeys) {
      expect(
        await store.lookup(miss),
        isNull,
        reason: 'expected miss for $miss',
      );
    }
  });

  test('lookup prefers userEdited over reviewed over auto', () async {
    final fixture = key();
    await store.put(
      key: fixture.key,
      kind: CacheKind.auto,
      translation: '자동',
      sourceText: fixture.source,
    );
    await store.put(
      key: fixture.key,
      kind: CacheKind.reviewed,
      translation: '검수',
      sourceText: fixture.source,
    );
    await store.put(
      key: fixture.key,
      kind: CacheKind.userEdited,
      translation: '사용자',
      sourceText: fixture.source,
    );

    expect((await store.lookup(fixture.key))!.translation, '사용자');

    // Drop userEdited row by overwriting is not supported; verify kind filter.
    expect(
      (await store.lookupKind(fixture.key, CacheKind.reviewed))!.translation,
      '검수',
    );
    expect(
      (await store.lookupKind(fixture.key, CacheKind.auto))!.translation,
      '자동',
    );
  });

  test('sourceHash is of raw text; sourceText column is debug-only', () async {
    final a = CacheHashes.sourceHash('Copper Ingot');
    final b = CacheHashes.sourceHash('Copper Ingot');
    final c = CacheHashes.sourceHash('copper ingot');
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.length, equals(64));
  });

  test('glossaryFingerprint ignores unrelated terms via applicable set', () {
    final applicable = [
      const GlossaryFingerprintInput(
        sourceTerm: 'Copper Ingot',
        targetTerm: '구리 주괴',
        caseSensitive: false,
      ),
    ];
    final withNoise = [
      ...applicable,
      const GlossaryFingerprintInput(
        sourceTerm: 'Unrelated',
        targetTerm: '무관',
        caseSensitive: false,
      ),
    ];
    expect(
      CacheHashes.glossaryFingerprint(applicable),
      isNot(equals(CacheHashes.glossaryFingerprint(withNoise))),
    );
  });
}

/// Pairs a human source string with its built [CacheKey].
class CacheKeyFixture {
  CacheKeyFixture({required this.source, required this.key});

  final String source;
  final CacheKey key;
}
