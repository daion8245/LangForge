import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/models/vocab_entry.dart';

VocabEntry _entry({int strength = 0, DateTime? lastSeen}) => VocabEntry(
  id: 'v',
  term: '물',
  gloss: 'water',
  romanization: 'mul',
  partOfSpeech: 'noun',
  example: '물 주세요.',
  exampleGloss: 'Water, please.',
  lessonId: 'l4',
  strength: strength,
  lastSeen: lastSeen,
);

void main() {
  group('strength', () {
    test('rises on a correct answer and caps at the maximum', () {
      final entry = _entry(strength: VocabEntry.maxStrength - 1);

      entry.record(correct: true);
      expect(entry.strength, VocabEntry.maxStrength);

      entry.record(correct: true);
      expect(entry.strength, VocabEntry.maxStrength);
    });

    test('falls on a wrong answer and floors at zero', () {
      final entry = _entry(strength: 1);

      entry.record(correct: false);
      expect(entry.strength, 0);

      entry.record(correct: false);
      expect(entry.strength, 0);
    });

    test('recording updates the practice counters', () {
      final entry = _entry();

      entry.record(correct: true);
      entry.record(correct: false);

      expect(entry.timesSeen, 2);
      expect(entry.timesCorrect, 1);
      expect(entry.accuracy, 0.5);
      expect(entry.lastSeen, isNotNull);
    });
  });

  group('decay', () {
    test('an unseen word does not decay', () {
      expect(_entry(strength: 4).effectiveStrength, 4);
    });

    test('one level is shed per elapsed window', () {
      final entry = _entry(
        strength: 5,
        lastSeen: DateTime.now().subtract(VocabEntry.decayWindow * 2),
      );

      expect(entry.effectiveStrength, 3);
    });

    test('decay floors at zero', () {
      final entry = _entry(
        strength: 2,
        lastSeen: DateTime.now().subtract(VocabEntry.decayWindow * 9),
      );

      expect(entry.effectiveStrength, 0);
      expect(entry.needsReview, isTrue);
    });

    test('a fresh strong word is not up for review', () {
      final entry = _entry(strength: 5, lastSeen: DateTime.now());
      expect(entry.needsReview, isFalse);
    });

    test('recording promotes from the decayed level, not the stored one', () {
      final entry = _entry(
        strength: 5,
        lastSeen: DateTime.now().subtract(VocabEntry.decayWindow * 3),
      );
      expect(entry.effectiveStrength, 2);

      entry.record(correct: true);
      expect(entry.strength, 3);
    });
  });

  test('copyFresh drops all practice history', () {
    final entry = _entry(strength: 4, lastSeen: DateTime.now())
      ..record(correct: true);

    final copy = entry.copyFresh();

    expect(copy.id, entry.id);
    expect(copy.term, entry.term);
    expect(copy.strength, 0);
    expect(copy.lastSeen, isNull);
    expect(copy.timesSeen, 0);
  });
}
