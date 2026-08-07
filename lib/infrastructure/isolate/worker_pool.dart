import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../domain/provider/translation_provider.dart';
import 'messages.dart';
import 'scan_worker.dart';

typedef ProgressCallback =
    void Function(int current, int total, String statusMessage);

/// Runs file scans on background isolates, several at a time.
///
/// Scanning 180 JARs one after another is the difference between seconds and
/// minutes (ROADMAP Phase 1 위험), and none of it may happen on the UI thread
/// (AGENTS.md 2.3).
abstract final class WorkerPool {
  /// Concurrent scans. Capped at 4: the work is IO-bound on the archive, and
  /// more isolates mostly buys memory pressure.
  static int get poolSize => math.min(Platform.numberOfProcessors, 4);

  /// Progress is reported no more often than this (AGENTS.md 4.5).
  static const Duration progressInterval = Duration(milliseconds: 100);

  static Future<List<FileScanResponse>> scanFiles(
    List<FileScanRequest> requests, {
    ProgressCallback? onProgress,
    CancellationToken? cancelToken,
    int? concurrency,
  }) async {
    final total = requests.length;
    if (total == 0) return const [];

    final results = List<FileScanResponse?>.filled(total, null);
    var nextIndex = 0;
    var completed = 0;
    var lastProgressAt = DateTime.fromMillisecondsSinceEpoch(0);

    void report(String message, {bool force = false}) {
      if (onProgress == null) return;
      final now = DateTime.now();
      if (!force && now.difference(lastProgressAt) < progressInterval) return;
      lastProgressAt = now;
      onProgress(completed, total, message);
    }

    report('탐색 준비 중…', force: true);

    Future<void> worker() async {
      while (true) {
        if (cancelToken?.isCancelled ?? false) return;
        if (nextIndex >= total) return;

        final index = nextIndex++;
        final request = requests[index];

        try {
          results[index] = await compute(scanFileInIsolate, request);
        } catch (error) {
          results[index] = FileScanResponse(
            filePath: request.filePath,
            originalName: request.filePath.split(RegExp(r'[/\\]')).last,
            sizeBytes: 0,
            sha256: '',
            isOk: false,
            rejectReason: '탐색 중 오류가 발생했습니다: $error',
          );
        }

        completed++;
        report('탐색 중… ($completed/$total)');
      }
    }

    final workerCount = (concurrency ?? poolSize).clamp(1, total);
    await Future.wait(List.generate(workerCount, (_) => worker()));

    report(
      (cancelToken?.isCancelled ?? false)
          ? '탐색을 취소했습니다.'
          : '탐색 완료 ($completed/$total)',
      force: true,
    );

    // A cancelled run returns what finished; the caller decides what to keep.
    return results.whereType<FileScanResponse>().toList();
  }
}
