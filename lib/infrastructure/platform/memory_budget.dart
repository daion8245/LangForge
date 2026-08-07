import 'dart:io' show Platform;
import 'dart:math' as math;

import 'app_platform.dart';

/// Per-platform limits for everything that can grow with project size.
///
/// The desktop numbers are the 1.5GB budget of TECHNICAL.md and match the
/// constants that were spelled out inline before Phase 13. The Android numbers
/// come from MOBILE.md 1.2: a phone process can be killed outright at a few
/// hundred MB, and an OOM kill is not an exception anything can catch, so the
/// limits have to sit well inside the heap rather than at the edge of it.
///
/// One place, so a limit can never be raised on desktop and silently left
/// dangerous on a phone.
abstract final class MemoryBudget {
  static bool get _mobile => AppPlatform.isMobile;

  /// Largest input file that is accepted at all.
  ///
  /// Over this the file is rejected *with a reason* and stays in the list —
  /// it is never dropped quietly.
  static int get maxInputFileBytes =>
      _mobile ? 128 * 1024 * 1024 : 512 * 1024 * 1024;

  /// Largest single entry inside an archive.
  static int get maxArchiveEntryBytes =>
      _mobile ? 16 * 1024 * 1024 : 64 * 1024 * 1024;

  /// Zip-bomb ceiling: total inflated bytes across one archive.
  static int get maxTotalInflatedBytes =>
      _mobile ? 384 * 1024 * 1024 : 2 * 1024 * 1024 * 1024;

  /// Largest `lang/*.json` that is parsed.
  static int get maxLangJsonBytes =>
      _mobile ? 8 * 1024 * 1024 : 32 * 1024 * 1024;

  /// Concurrent scan isolates. Each one holds an archive buffer, so this is
  /// the single biggest multiplier on peak memory during a scan.
  static int get scanConcurrency {
    if (_mobile) return 2;
    return math.min(_numberOfProcessors, 4);
  }

  /// Entry rows held by the list at once, per loaded page.
  static int get entryPageSize => _mobile ? 100 : 200;

  /// Rows buffered before a translation run flushes them to the database.
  static int get flushChunkSize => _mobile ? 300 : 1000;

  /// Caps whatever the provider itself allows.
  ///
  /// Each in-flight request holds a request body, a response buffer, and a
  /// retry queue slot; on a phone two is the point where throughput stops
  /// improving and memory keeps growing.
  static int maxConcurrentRequests(int providerLimit) =>
      _mobile ? math.min(providerLimit, 2) : providerLimit;

  /// Free space below which a file import is refused (MOBILE.md 1.4).
  ///
  /// The picker copies every chosen file into the app cache on Android, so an
  /// import needs roughly its own size again in free space. Asking for twice
  /// that leaves room for the database rows the scan then writes.
  static int requiredFreeBytesFor(int importedBytes) => importedBytes * 2;

  static int get _numberOfProcessors {
    try {
      return Platform.numberOfProcessors;
    } on UnsupportedError {
      // No dart:io host (should not happen for a shipped build).
      return 1;
    }
  }
}
