import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/model/entry_status.dart';
import '../../domain/validation/existing_translation_classifier.dart';
import '../../infrastructure/archive/directory_reader.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/isolate/messages.dart';
import '../../domain/provider/translation_provider.dart' show CancellationToken;
import '../../infrastructure/isolate/worker_pool.dart';
import '../db_provider.dart';

class ScanState {
  final bool isScanning;
  final int totalFiles;
  final int scannedFiles;
  final String? currentStatusMessage;
  final List<String> rejectedSummary;

  /// namespace -> keys present only in the old target file (TECHNICAL.md 7.2).
  final Map<String, List<String>> staleKeysByNamespace;
  final String? activeFileId;
  final String? activeNamespaceId;
  final String? searchQuery;

  const ScanState({
    this.isScanning = false,
    this.totalFiles = 0,
    this.scannedFiles = 0,
    this.currentStatusMessage,
    this.rejectedSummary = const [],
    this.staleKeysByNamespace = const {},
    this.activeFileId,
    this.activeNamespaceId,
    this.searchQuery,
  });

  ScanState copyWith({
    bool? isScanning,
    int? totalFiles,
    int? scannedFiles,
    String? currentStatusMessage,
    List<String>? rejectedSummary,
    Map<String, List<String>>? staleKeysByNamespace,
    String? activeFileId,
    String? activeNamespaceId,
    String? searchQuery,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      totalFiles: totalFiles ?? this.totalFiles,
      scannedFiles: scannedFiles ?? this.scannedFiles,
      currentStatusMessage: currentStatusMessage ?? this.currentStatusMessage,
      rejectedSummary: rejectedSummary ?? this.rejectedSummary,
      staleKeysByNamespace: staleKeysByNamespace ?? this.staleKeysByNamespace,
      activeFileId: activeFileId ?? this.activeFileId,
      activeNamespaceId: activeNamespaceId ?? this.activeNamespaceId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ScanController extends Notifier<ScanState> {
  static const _uuid = Uuid();

  CancellationToken? _scanCancelToken;

  /// Stops an in-progress scan. Files already persisted are kept; the rest are
  /// simply not added (ROADMAP Phase 1 완료 조건).
  void cancelScan() {
    _scanCancelToken?.cancel();
  }

  /// Warnings are stored as JSON so more can be added without a migration.
  static String? _encodeWarning(ExistingTranslationWarning? warning) {
    if (warning == null) return null;
    return jsonEncode([warning.name]);
  }

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  ScanState build() => const ScanState();

  void setActiveFile(String? fileId) {
    state = state.copyWith(activeFileId: fileId, activeNamespaceId: null);
  }

  void setActiveNamespace(String? nsId) {
    state = state.copyWith(activeNamespaceId: nsId);
  }

  Future<void> updateUserTranslation(String entryId, String text) async {
    final trimmed = text.trim();
    // Clearing the field reverts the entry to 대기 (ROADMAP 4.4).
    final newStatus = trimmed.isEmpty
        ? EntryStatus.wait.wireName
        : EntryStatus.confirm.wireName;

    await (_db.update(
      _db.entries,
    )..where((tbl) => tbl.id.equals(entryId))).write(
      EntriesCompanion(
        userTranslation: Value(trimmed.isEmpty ? null : text),
        userEdited: const Value(true),
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetEntryToWait(String entryId) async {
    await (_db.update(
      _db.entries,
    )..where((tbl) => tbl.id.equals(entryId))).write(
      EntriesCompanion(
        userTranslation: const Value(null),
        userEdited: const Value(false),
        status: Value(EntryStatus.wait.wireName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> keepSourceText(String entryId) async {
    final entry = await (_db.select(
      _db.entries,
    )..where((tbl) => tbl.id.equals(entryId))).getSingleOrNull();
    if (entry == null) return;

    await (_db.update(
      _db.entries,
    )..where((tbl) => tbl.id.equals(entryId))).write(
      EntriesCompanion(
        userTranslation: Value(entry.sourceText),
        userEdited: const Value(true),
        status: Value(EntryStatus.fallback.wireName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> addFiles(List<String> paths) async {
    final requests = <FileScanRequest>[];
    for (final path in paths) {
      final ext = p.extension(path).toLowerCase();
      if (ext == '.jar' || ext == '.zip') {
        requests.add(
          FileScanRequest(filePath: path, kind: ext == '.jar' ? 'jar' : 'zip'),
        );
      }
    }

    if (requests.isEmpty) return;
    await _processScanRequests(requests);
  }

  Future<void> addDirectory(String dirPath) async {
    final archiveFiles = await DirectoryReader.findArchiveFiles(dirPath);
    final requests = archiveFiles
        .map(
          (f) => FileScanRequest(
            filePath: f.path,
            kind: p.extension(f.path).toLowerCase() == '.jar' ? 'jar' : 'zip',
          ),
        )
        .toList();

    if (requests.isEmpty) {
      // Treat directory itself as unpacked folder if no jars inside
      requests.add(FileScanRequest(filePath: dirPath, kind: 'directory'));
    }

    await _processScanRequests(requests);
  }

  Future<void> _processScanRequests(List<FileScanRequest> requests) async {
    state = state.copyWith(
      isScanning: true,
      totalFiles: requests.length,
      scannedFiles: 0,
      currentStatusMessage: '탐색 준비 중...',
      rejectedSummary: const <String>[],
      staleKeysByNamespace: const <String, List<String>>{},
    );

    // 1. Get existing file SHA-256 hashes to prevent duplicates
    final existingFiles = await _db.select(_db.inputFiles).get();
    final existingHashes = existingFiles.map((f) => f.sha256).toSet();

    final cancelToken = CancellationToken();
    _scanCancelToken = cancelToken;

    final scanResponses = await WorkerPool.scanFiles(
      requests,
      cancelToken: cancelToken,
      onProgress: (current, total, msg) {
        state = state.copyWith(
          scannedFiles: current,
          totalFiles: total,
          currentStatusMessage: msg,
        );
      },
    );

    final rejected = <String>[];
    final staleKeysByNamespace = <String, List<String>>{};
    final now = DateTime.now();

    // 2. Process responses & persist to DB in batches
    for (final resp in scanResponses) {
      if (cancelToken.isCancelled) break;
      if (!resp.isOk) {
        rejected.add('${resp.originalName}: ${resp.rejectReason}');
        continue;
      }

      if (existingHashes.contains(resp.sha256)) {
        rejected.add('${resp.originalName}: 이미 추가된 중복 파일입니다 (SHA-256 일치).');
        continue;
      }
      existingHashes.add(resp.sha256);

      final inputFileId = _uuid.v4();

      // Insert InputFile
      await _db
          .into(_db.inputFiles)
          .insert(
            InputFilesCompanion.insert(
              id: inputFileId,
              originalName: resp.originalName,
              absolutePath: resp.filePath,
              kind: p.extension(resp.filePath).toLowerCase() == '.jar'
                  ? 'jar'
                  : 'zip',
              sizeBytes: resp.sizeBytes,
              sha256: resp.sha256,
              addedAt: now,
              scanState: 'ok',
            ),
          );

      for (final ns in resp.namespaces) {
        final nsId = _uuid.v4();
        int totalKeyCount = 0;

        // Find source lang file for entries
        DiscoveredLangFileData? sourceLangData;
        DiscoveredLangFileData? existingTargetLangData;

        for (final lf in ns.langFiles) {
          if (lf.role == 'source') sourceLangData = lf;
          if (lf.role == 'existingTarget') existingTargetLangData = lf;
        }

        totalKeyCount = sourceLangData?.keyCount ?? 0;

        // Insert Namespace
        await _db
            .into(_db.namespaces)
            .insert(
              NamespacesCompanion.insert(
                id: nsId,
                inputFileId: inputFileId,
                name: ns.namespace,
                state: ns.state,
                errorMessage: Value(ns.errorMessage),
                errorLine: Value(ns.errorLine),
                keyCount: Value(totalKeyCount),
              ),
            );

        // Insert LanguageFiles
        for (final lf in ns.langFiles) {
          final lfId = _uuid.v4();
          await _db
              .into(_db.languageFiles)
              .insert(
                LanguageFilesCompanion.insert(
                  id: lfId,
                  namespaceId: nsId,
                  rawCode: lf.rawCode,
                  code: lf.code,
                  entryPath: lf.entryPath,
                  keyCount: lf.keyCount,
                  role: lf.role,
                ),
              );
        }

        // Insert Entries (if source lang exists)
        if (sourceLangData != null) {
          final entryCompanions = <EntriesCompanion>[];
          int order = 0;

          // A namespace whose target file failed the precheck must not import
          // any of its values (TECHNICAL.md 7.2).
          final targetFileCorrupt = ns.state == 'jsonError';

          for (final key in sourceLangData.keyOrder) {
            final sourceText = sourceLangData.entries[key] ?? '';
            final existingTrans = existingTargetLangData?.entries[key];

            final verdict = ExistingTranslationClassifier.classify(
              sourceText: sourceText,
              existingText: existingTrans,
              targetFileCorrupt: targetFileCorrupt,
            );

            entryCompanions.add(
              EntriesCompanion.insert(
                id: _uuid.v4(),
                namespaceId: nsId,
                key: key,
                keyOrder: order++,
                sourceText: sourceText,
                existingTranslation: Value(existingTrans),
                status: verdict.status.wireName,
                warningsJson: Value(_encodeWarning(verdict.warning)),
                updatedAt: now,
              ),
            );
          }

          // Keys that exist only in the old target file are dropped from
          // output; record them so the report can list what was left behind.
          final staleKeys = ExistingTranslationClassifier.findStaleKeys(
            sourceKeys: sourceLangData.keyOrder,
            existingKeys: existingTargetLangData?.keyOrder ?? const <String>[],
          );
          if (staleKeys.isNotEmpty) {
            staleKeysByNamespace[ns.namespace] = staleKeys;
          }

          // Chunk DB batch insertion in 1,000s
          const chunkSize = 1000;
          for (int i = 0; i < entryCompanions.length; i += chunkSize) {
            final chunk = entryCompanions.sublist(
              i,
              i + chunkSize > entryCompanions.length
                  ? entryCompanions.length
                  : i + chunkSize,
            );
            await _db.batch((b) {
              b.insertAll(_db.entries, chunk);
            });
          }
        }
      }
    }

    _scanCancelToken = null;
    state = state.copyWith(
      isScanning: false,
      currentStatusMessage: cancelToken.isCancelled ? '탐색을 취소했습니다.' : null,
      rejectedSummary: rejected,
      staleKeysByNamespace: staleKeysByNamespace,
    );
  }
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
