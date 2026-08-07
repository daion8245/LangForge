import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/glossary/glossary_policy.dart';
import 'package:langforge/domain/glossary/glossary_term.dart';

GlossaryTerm term({
  String id = 't1',
  String source = 'Copper Ingot',
  String target = '구리 주괴',
  String? namespace,
  bool caseSensitive = false,
}) {
  return GlossaryTerm(
    id: id,
    sourceTerm: source,
    targetTerm: target,
    sourceLang: 'en_us',
    targetLang: 'ko_kr',
    namespace: namespace,
    caseSensitive: caseSensitive,
  );
}

void main() {
  group('GlossaryPolicy.exactMatch', () {
    test('matches trimmed full string only', () {
      expect(GlossaryPolicy.exactMatch('  Copper Ingot  ', [term()]), '구리 주괴');
    });

    test('does not match partial containment', () {
      expect(GlossaryPolicy.exactMatch('Copper Ingot Block', [term()]), isNull);
    });

    test('respects caseSensitive', () {
      expect(
        GlossaryPolicy.exactMatch('copper ingot', [term(caseSensitive: true)]),
        isNull,
      );
      expect(
        GlossaryPolicy.exactMatch('copper ingot', [term(caseSensitive: false)]),
        '구리 주괴',
      );
    });
  });

  group('GlossaryPolicy.isViolation', () {
    test('fires only when source has term and result lacks target', () {
      expect(
        GlossaryPolicy.isViolation(
          sourceText: 'Use Copper Ingot here',
          translation: '여기를 사용',
          term: term(),
        ),
        isTrue,
      );
      expect(
        GlossaryPolicy.isViolation(
          sourceText: 'Use Copper Ingot here',
          translation: '구리 주괴를 사용',
          term: term(),
        ),
        isFalse,
      );
      expect(
        GlossaryPolicy.isViolation(
          sourceText: 'Iron only',
          translation: '철만',
          term: term(),
        ),
        isFalse,
      );
    });
  });

  group('GlossaryPolicy.mergeProjectOverGlobal', () {
    test('project wins on same identity', () {
      final merged = GlossaryPolicy.mergeProjectOverGlobal(
        global: [term(id: 'g', target: '전역')],
        project: [term(id: 'p', target: '프로젝트')],
      );
      expect(merged.single.targetTerm, '프로젝트');
    });
  });
}
