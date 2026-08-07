import 'token_pattern.dart';

class TokenChipInfo {
  final String token;
  final int sourceCount;
  final int targetCount;
  final bool isMatch;

  const TokenChipInfo({
    required this.token,
    required this.sourceCount,
    required this.targetCount,
    required this.isMatch,
  });
}

class MultisetValidationResult {
  final bool isMatch;
  final List<TokenChipInfo> tokenChips;

  const MultisetValidationResult({
    required this.isMatch,
    required this.tokenChips,
  });
}

abstract final class MultisetValidator {
  /// Computes a multiset bag of tokens (token string -> occurrence count).
  static Map<String, int> bagOf(String text) {
    final bag = <String, int>{};
    for (final match in tokenPattern.allMatches(text)) {
      final tokenStr = match.group(0)!;
      bag.update(tokenStr, (count) => count + 1, ifAbsent: () => 1);
    }
    return bag;
  }

  /// Compares token multisets of [sourceText] and [translatedText].
  static MultisetValidationResult validate(
    String sourceText,
    String translatedText,
  ) {
    final sourceBag = bagOf(sourceText);
    final targetBag = bagOf(translatedText);

    final allTokens = <String>{...sourceBag.keys, ...targetBag.keys};
    final chips = <TokenChipInfo>[];
    bool isOverallMatch = true;

    for (final token in allTokens) {
      final sCount = sourceBag[token] ?? 0;
      final tCount = targetBag[token] ?? 0;
      final isMatch = sCount == tCount;

      if (!isMatch) {
        isOverallMatch = false;
      }

      chips.add(
        TokenChipInfo(
          token: token,
          sourceCount: sCount,
          targetCount: tCount,
          isMatch: isMatch,
        ),
      );
    }

    return MultisetValidationResult(isMatch: isOverallMatch, tokenChips: chips);
  }
}
