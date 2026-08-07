import 'package:archive/archive.dart';

import '../platform/memory_budget.dart';

/// Size ceilings every archive read is held to.
///
/// The four size limits follow the host: a phone process is killed outright
/// well below the desktop budget, so its ceilings sit inside the heap rather
/// than at the edge of it (MOBILE.md 1.2). The two shape limits — the
/// compression ratio and the entry count — are zip-bomb defences and do not
/// vary; they are about what an archive is allowed to *claim*, not about how
/// much memory the host has.
abstract final class ArchiveLimits {
  static int get maxInputFileBytes => MemoryBudget.maxInputFileBytes;
  static int get maxEntryBytes => MemoryBudget.maxArchiveEntryBytes;
  static int get maxTotalInflated => MemoryBudget.maxTotalInflatedBytes;
  static int get maxLangJsonBytes => MemoryBudget.maxLangJsonBytes;

  static const maxCompressionRatio = 200; // 200:1
  static const maxEntryCount = 100000;
  static const maxValueLength = 8192; // Max value length in chars
}

/// Checks if an entry path in a ZIP/JAR archive is safe from path traversal (Zip Slip).
bool isSafeEntryPath(String raw) {
  // 1. Normalize backslashes to forward slashes (Windows archives)
  final unified = raw.replaceAll('\\', '/');

  // 2. Reject absolute paths starting with /
  if (unified.startsWith('/')) return false;

  // 3. Reject drive letters (C:/...)
  if (RegExp(r'^[A-Za-z]:').hasMatch(unified)) return false;

  // 4. Reject UNC paths (//...)
  if (unified.startsWith('//')) return false;

  // 5. Reject '..' segments (checking per segment, not just contains('..'))
  for (final seg in unified.split('/')) {
    if (seg == '..') return false;
  }

  // 6. Reject NUL and control characters (ASCII < 0x20)
  if (unified.codeUnits.any((c) => c < 0x20)) return false;

  return true;
}

class ArchiveGuard {
  int _accumulatedInflatedBytes = 0;
  int _entryCount = 0;

  void reset() {
    _accumulatedInflatedBytes = 0;
    _entryCount = 0;
  }

  /// Validates an archive file entry against Zip Slip, Zip Bomb, and size limits.
  void validateEntry(ArchiveFile file) {
    _entryCount++;
    if (_entryCount > ArchiveLimits.maxEntryCount) {
      throw ArchiveGuardException(
        'Archive exceeds maximum entry count limit (${ArchiveLimits.maxEntryCount}).',
      );
    }

    if (!isSafeEntryPath(file.name)) {
      throw ArchiveGuardException(
        'Potentially unsafe path in archive entry: ${file.name}',
      );
    }

    final uncompressedSize = file.size;
    if (uncompressedSize > ArchiveLimits.maxEntryBytes) {
      throw ArchiveGuardException(
        'Archive entry ${file.name} exceeds size limit ($uncompressedSize > ${ArchiveLimits.maxEntryBytes}).',
      );
    }

    final compressedSize = file.rawContent?.length ?? 1;
    if (compressedSize > 0 && uncompressedSize > 0) {
      final ratio = uncompressedSize / compressedSize;
      if (ratio > ArchiveLimits.maxCompressionRatio) {
        throw ArchiveGuardException(
          'Archive entry ${file.name} exceeds compression ratio limit (${ratio.toStringAsFixed(1)}:1 > ${ArchiveLimits.maxCompressionRatio}:1).',
        );
      }
    }

    _accumulatedInflatedBytes += uncompressedSize;
    if (_accumulatedInflatedBytes > ArchiveLimits.maxTotalInflated) {
      throw ArchiveGuardException(
        'Total inflated archive size exceeds limit (${ArchiveLimits.maxTotalInflated} bytes).',
      );
    }
  }
}

class ArchiveGuardException implements Exception {
  final String message;
  const ArchiveGuardException(this.message);

  @override
  String toString() => 'ArchiveGuardException: $message';
}
