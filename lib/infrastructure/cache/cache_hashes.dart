import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/cache/glossary_fingerprint_input.dart';

/// SHA-256 helpers for cache keys. See TECHNICAL.md 7.5.
abstract final class CacheHashes {
  /// Hash of the raw source before token protection.
  static String sourceHash(String sourceText) =>
      sha256.convert(utf8.encode(sourceText)).toString();

  /// Fingerprint of glossary rows that apply to the current entry.
  ///
  /// Empty applicable set → hash of the empty string (stable miss/hit).
  static String glossaryFingerprint(
    Iterable<GlossaryFingerprintInput> applicable,
  ) {
    final sorted = applicable.toList()..sort();
    final payload = sorted.map((e) => e.canonicalLine).join('\n');
    return sha256.convert(utf8.encode(payload)).toString();
  }
}
