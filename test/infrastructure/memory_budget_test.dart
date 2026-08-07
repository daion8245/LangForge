import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/archive/archive_guard.dart';
import 'package:langforge/infrastructure/platform/app_platform.dart';
import 'package:langforge/infrastructure/platform/memory_budget.dart';

void main() {
  tearDown(() => AppPlatform.debugOverride(null));

  group('AppPlatform', () {
    test('Android counts as mobile, Windows does not', () {
      AppPlatform.debugOverride(TargetPlatform.android);
      expect(AppPlatform.isMobile, isTrue);
      expect(AppPlatform.isDesktop, isFalse);

      AppPlatform.debugOverride(TargetPlatform.windows);
      expect(AppPlatform.isMobile, isFalse);
      expect(AppPlatform.isDesktop, isTrue);
    });
  });

  group('MemoryBudget', () {
    test('every phone ceiling sits below its desktop counterpart', () {
      AppPlatform.debugOverride(TargetPlatform.windows);
      final desktop = <String, int>{
        'input': MemoryBudget.maxInputFileBytes,
        'entry': MemoryBudget.maxArchiveEntryBytes,
        'inflated': MemoryBudget.maxTotalInflatedBytes,
        'langJson': MemoryBudget.maxLangJsonBytes,
        'page': MemoryBudget.entryPageSize,
        'flush': MemoryBudget.flushChunkSize,
        'concurrency': MemoryBudget.scanConcurrency,
      };

      AppPlatform.debugOverride(TargetPlatform.android);
      final mobile = <String, int>{
        'input': MemoryBudget.maxInputFileBytes,
        'entry': MemoryBudget.maxArchiveEntryBytes,
        'inflated': MemoryBudget.maxTotalInflatedBytes,
        'langJson': MemoryBudget.maxLangJsonBytes,
        'page': MemoryBudget.entryPageSize,
        'flush': MemoryBudget.flushChunkSize,
        'concurrency': MemoryBudget.scanConcurrency,
      };

      for (final key in desktop.keys) {
        expect(
          mobile[key],
          lessThan(desktop[key]!),
          reason: '$key must be lower on a phone (MOBILE.md 1.2)',
        );
      }
    });

    test('the provider request cap is only tightened, never raised', () {
      AppPlatform.debugOverride(TargetPlatform.windows);
      expect(MemoryBudget.maxConcurrentRequests(8), 8);
      expect(MemoryBudget.maxConcurrentRequests(1), 1);

      AppPlatform.debugOverride(TargetPlatform.android);
      expect(MemoryBudget.maxConcurrentRequests(8), 2);
      // A provider that allows fewer than the phone cap still wins.
      expect(MemoryBudget.maxConcurrentRequests(1), 1);
    });
  });

  group('ArchiveLimits', () {
    test('size ceilings follow the platform', () {
      AppPlatform.debugOverride(TargetPlatform.windows);
      expect(ArchiveLimits.maxInputFileBytes, 512 * 1024 * 1024);

      AppPlatform.debugOverride(TargetPlatform.android);
      expect(ArchiveLimits.maxInputFileBytes, 128 * 1024 * 1024);
    });

    test('zip-bomb shape limits do not', () {
      AppPlatform.debugOverride(TargetPlatform.windows);
      final desktopRatio = ArchiveLimits.maxCompressionRatio;
      final desktopCount = ArchiveLimits.maxEntryCount;

      AppPlatform.debugOverride(TargetPlatform.android);
      expect(ArchiveLimits.maxCompressionRatio, desktopRatio);
      expect(ArchiveLimits.maxEntryCount, desktopCount);
    });
  });
}
