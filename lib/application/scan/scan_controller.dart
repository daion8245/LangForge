import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/model/entry_status.dart';
// This file declares its own ScanState (the UI state), which shadows the
// domain enum of the same name. The prefix keeps the persisted wire values
// type-checked instead of spelling them as bare strings.
import '../../domain/model/entry_status.dart' as model;
import '../../domain/validation/conflict_detector.dart';
import '../../domain/validation/existing_translation_classifier.dart';
import '../../infrastructure/db/row_mappers.dart';
import '../project/project_session.dart';
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

  /// `null` means "leave as is" for every field, so clearing a nullable one
  /// needs its own flag — otherwise Esc could never empty the search box and
  /// deselecting a namespace would be impossible.
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
    bool clearStatusMessage = false,
    bool clearActiveFile = false,
    bool clearActiveNamespace = false,
    bool clearSearchQuery = false,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      totalFiles: totalFiles ?? this.totalFiles,
      scannedFiles: scannedFiles ?? this.scannedFiles,
      currentStatusMessage: clearStatusMessage
          ? null
          : (currentStatusMessage ?? this.currentStatusMessage),
      rejectedSummary: rejectedSummary ?? this.rejectedSummary,
      staleKeysByNamespace: staleKeysByNamespace ?? this.staleKeysByNamespace,
      activeFileId: clearActiveFile
          ? null
          : (activeFileId ?? this.activeFileId),
      activeNamespaceId: clearActiveNamespace
          ? null
          : (activeNamespaceId ?? this.activeNamespaceId),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
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

  ProjectSessionController get _session =>
      ref.read(projectSessionProvider.notifier);

  @override
  ScanState build() => const ScanState();

  /// Recomputes the conflict table (AC-8.3 · AC-8.5).
  ///
  /// Candidate keys are found in SQL so a 48,000-key project never has to be
  /// pulled into memory; only the keys that already look conflicted are loaded
  /// and handed to the domain rule, which stays the single definition of what
  /// counts as a conflict.
  Future<int> refreshConflicts() async {
    final candidates = await _db
        .customSelect(
          'SELECT n.name AS ns_name, e.key AS entry_key '
          'FROM entries e JOIN namespaces n ON n.id = e.namespace_id '
          'WHERE n.excluded = 0 '
          'GROUP BY n.name, e.key '
          'HAVING COUNT(DISTINCT e.source_text) > 1',
        )
        .get();

    await _db.delete(_db.conflicts).go();
    if (candidates.isEmpty) return 0;

    final conflictedKeys = candidates
        .map((row) => row.read<String>('entry_key'))
        .toSet()
        .toList();

    final namespaceRows = await _db.select(_db.namespaces).get();
    final entryRows = await (_db.select(
      _db.entries,
    )..where((tbl) => tbl.key.isIn(conflictedKeys))).get();

    final conflicts = ConflictDetector.detect(
      namespaces: namespaceRows.toDomain(),
      entries: entryRows.toDomain(),
    );
    if (conflicts.isEmpty) return 0;

    await _db.batch((b) {
      b.insertAll(_db.conflicts, [
        for (final conflict in conflicts)
          ConflictsCompanion.insert(
            id: _uuid.v4(),
            namespaceName: conflict.namespaceName,
            key: conflict.key,
            participantsJson: jsonEncode([
              {'sourceText': conflict.sourceTextA},
              {'sourceText': conflict.sourceTextB},
            ]),
          ),
      ]);
    });

    return conflicts.length;
  }

  void setActiveFile(String? fileId) {
    state = state.copyWith(
      activeFileId: fileId,
      clearActiveFile: fileId == null,
      clearActiveNamespace: true,
    );
  }

  void setActiveNamespace(String? nsId) {
    state = state.copyWith(
      activeNamespaceId: nsId,
      clearActiveNamespace: nsId == null,
    );
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
    _session.markDirty();
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
    _session.markDirty();
  }

  /// Excludes or re-includes one namespace (AC-4.4).
  ///
  /// `selected` moves with `excluded` so the tree checkbox and the export set
  /// never disagree.
  Future<void> setNamespaceExcluded(String namespaceId, bool excluded) async {
    await (_db.update(
      _db.namespaces,
    )..where((tbl) => tbl.id.equals(namespaceId))).write(
      NamespacesCompanion(
        excluded: Value(excluded),
        selected: Value(!excluded),
      ),
    );
    _session.markDirty();
  }

  /// Turns every namespace under one input file on or off at once (AC-8.2).
  Future<void> setInputFileEnabled(String inputFileId, bool enabled) async {
    await (_db.update(_db.inputFiles)
          ..where((tbl) => tbl.id.equals(inputFileId)))
        .write(InputFilesCompanion(enabled: Value(enabled)));

    await (_db.update(
      _db.namespaces,
    )..where((tbl) => tbl.inputFileId.equals(inputFileId))).write(
      NamespacesCompanion(excluded: Value(!enabled), selected: Value(enabled)),
    );
    _session.markDirty();
  }

  /// Names a different language file as the source for a namespace that has no
  /// `en_us.json` (AC-4.3).
  ///
  /// The archive is re-read for this one file: the scan keeps only key counts,
  /// not the parsed values, so the entries have to come from the JAR again.
  /// Values the user already has are re-applied through the classifier, so
  /// choosing a source does not discard existing translations (AC-10.7).
  Future<void> setNamespaceSource(
    String namespaceId,
    String languageFileId,
  ) async {
    final namespace = await (_db.select(
      _db.namespaces,
    )..where((tbl) => tbl.id.equals(namespaceId))).getSingleOrNull();
    if (namespace == null) return;

    final chosen = await (_db.select(
      _db.languageFiles,
    )..where((tbl) => tbl.id.equals(languageFileId))).getSingleOrNull();
    if (chosen == null) return;

    final inputFile = await (_db.select(
      _db.inputFiles,
    )..where((tbl) => tbl.id.equals(namespace.inputFileId))).getSingleOrNull();
    if (inputFile == null) return;

    state = state.copyWith(
      isScanning: true,
      currentStatusMessage: '원본 언어를 적용하는 중…',
    );

    final responses = await WorkerPool.scanFiles([
      FileScanRequest(filePath: inputFile.absolutePath, kind: inputFile.kind),
    ]);

    final nsData = responses
        .expand((r) => r.namespaces)
        .where((ns) => ns.namespace == namespace.name)
        .firstOrNull;
    final sourceData = nsData?.langFiles
        .where((lf) => lf.entryPath == chosen.entryPath)
        .firstOrNull;

    if (sourceData == null) {
      state = state.copyWith(
        isScanning: false,
        clearStatusMessage: true,
        rejectedSummary: ['${namespace.name}: 선택한 원본 파일을 다시 읽지 못했습니다.'],
      );
      return;
    }

    final existingTargetData = nsData?.langFiles
        .where((lf) => lf.role == 'existingTarget')
        .firstOrNull;

    await _db.transaction(() async {
      await (_db.update(_db.languageFiles)
            ..where((tbl) => tbl.namespaceId.equals(namespaceId)))
          .write(const LanguageFilesCompanion(role: Value('other')));
      await (_db.update(_db.languageFiles)
            ..where((tbl) => tbl.id.equals(languageFileId)))
          .write(const LanguageFilesCompanion(role: Value('source')));

      await _replaceNamespaceEntries(
        namespaceId: namespaceId,
        sourceData: sourceData,
        existingTargetData: existingTargetData,
      );

      await (_db.update(
        _db.namespaces,
      )..where((tbl) => tbl.id.equals(namespaceId))).write(
        NamespacesCompanion(
          state: Value(NamespaceState.ok.wireName),
          sourceOverride: Value(chosen.code),
          keyCount: Value(sourceData.keyOrder.length),
          excluded: const Value(false),
          selected: const Value(true),
        ),
      );
    });

    await refreshConflicts();
    state = state.copyWith(
      isScanning: false,
      currentStatusMessage: '${namespace.name}: 원본을 ${chosen.code} 로 지정했습니다.',
    );
    _session.markDirty();
  }

  /// Writes one discovered namespace, its language files, and its entries.
  ///
  /// Returns the keys that exist only in the old target file, so the caller can
  /// record them for the report (TECHNICAL.md 7.2).
  Future<List<String>> _insertNamespace({
    required String inputFileId,
    required DiscoveredNamespaceData nsData,
    required DateTime addedAt,
  }) async {
    final nsId = _uuid.v4();

    DiscoveredLangFileData? sourceLangData;
    DiscoveredLangFileData? existingTargetLangData;
    for (final lf in nsData.langFiles) {
      if (lf.role == 'source') sourceLangData = lf;
      if (lf.role == 'existingTarget') existingTargetLangData = lf;
    }

    await _db
        .into(_db.namespaces)
        .insert(
          NamespacesCompanion.insert(
            id: nsId,
            inputFileId: inputFileId,
            name: nsData.namespace,
            state: nsData.state,
            errorMessage: Value(nsData.errorMessage),
            errorLine: Value(nsData.errorLine),
            keyCount: Value(sourceLangData?.keyCount ?? 0),
          ),
        );

    for (final lf in nsData.langFiles) {
      await _db
          .into(_db.languageFiles)
          .insert(
            LanguageFilesCompanion.insert(
              id: _uuid.v4(),
              namespaceId: nsId,
              rawCode: lf.rawCode,
              code: lf.code,
              entryPath: lf.entryPath,
              keyCount: lf.keyCount,
              role: lf.role,
            ),
          );
    }

    final source = sourceLangData;
    if (source == null) return const [];

    // A namespace whose target file failed the precheck must not import any of
    // its values (TECHNICAL.md 7.2).
    final targetFileCorrupt = nsData.state == 'jsonError';

    final entryCompanions = <EntriesCompanion>[];
    var order = 0;
    for (final key in source.keyOrder) {
      final sourceText = source.entries[key] ?? '';
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
          updatedAt: addedAt,
        ),
      );
    }

    const chunkSize = 1000;
    for (var i = 0; i < entryCompanions.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, entryCompanions.length);
      await _db.batch((b) {
        b.insertAll(_db.entries, entryCompanions.sublist(i, end));
      });
    }

    return ExistingTranslationClassifier.findStaleKeys(
      sourceKeys: source.keyOrder,
      existingKeys: existingTargetLangData?.keyOrder ?? const <String>[],
    );
  }

  /// Rebuilds one namespace's entries from a fresh read of the archive.
  ///
  /// Re-scanning must never turn finished work back into 대기 (AGENTS.md 5.7 ·
  /// AC-10.7). A key whose source text is unchanged keeps everything it had:
  /// its status, its translation, and the user's edit. Only a key that is new,
  /// or whose source text actually changed, is re-derived — and even then a
  /// value the user typed is kept and flagged 확인 필요 rather than discarded.
  Future<void> _replaceNamespaceEntries({
    required String namespaceId,
    required DiscoveredLangFileData sourceData,
    required DiscoveredLangFileData? existingTargetData,
  }) async {
    final previous = await (_db.select(
      _db.entries,
    )..where((tbl) => tbl.namespaceId.equals(namespaceId))).get();
    final previousByKey = {for (final e in previous) e.key: e};

    await (_db.delete(
      _db.entries,
    )..where((tbl) => tbl.namespaceId.equals(namespaceId))).go();

    final now = DateTime.now();
    final companions = <EntriesCompanion>[];
    var order = 0;

    for (final key in sourceData.keyOrder) {
      final sourceText = sourceData.entries[key] ?? '';
      final existingTrans = existingTargetData?.entries[key];
      final prior = previousByKey[key];

      final verdict = ExistingTranslationClassifier.classify(
        sourceText: sourceText,
        existingText: existingTrans,
      );

      final sourceUnchanged = prior != null && prior.sourceText == sourceText;

      if (sourceUnchanged) {
        companions.add(
          EntriesCompanion.insert(
            id: prior.id,
            namespaceId: namespaceId,
            key: key,
            keyOrder: order++,
            sourceText: sourceText,
            // The file is the authority on what the old target JSON says; the
            // rest of the row is the project's own work and is carried over.
            existingTranslation: Value(existingTrans),
            newTranslation: Value(prior.newTranslation),
            userTranslation: Value(prior.userTranslation),
            userEdited: Value(prior.userEdited),
            status: prior.status,
            warningsJson: Value(prior.warningsJson),
            updatedAt: prior.updatedAt,
          ),
        );
        continue;
      }

      // The source string itself changed, so an automatic translation of the
      // old string is stale. A value the user typed is still kept, but it now
      // needs their eyes (TECHNICAL.md 7.1).
      final keepsUserEdit = prior != null && prior.userEdited;

      companions.add(
        EntriesCompanion.insert(
          id: prior?.id ?? _uuid.v4(),
          namespaceId: namespaceId,
          key: key,
          keyOrder: order++,
          sourceText: sourceText,
          existingTranslation: Value(existingTrans),
          userTranslation: Value(keepsUserEdit ? prior.userTranslation : null),
          userEdited: Value(keepsUserEdit),
          status: keepsUserEdit
              ? EntryStatus.confirm.wireName
              : verdict.status.wireName,
          warningsJson: Value(_encodeWarning(verdict.warning)),
          updatedAt: now,
        ),
      );
    }

    const chunkSize = 1000;
    for (var i = 0; i < companions.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, companions.length);
      final chunk = companions.sublist(i, end);
      await _db.batch((b) => b.insertAll(_db.entries, chunk));
    }
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
    _session.markDirty();
  }

  void setSearchQuery(String? query) {
    final trimmed = query?.trim();
    final isEmpty = trimmed == null || trimmed.isEmpty;
    state = state.copyWith(searchQuery: trimmed, clearSearchQuery: isEmpty);
  }

  Future<void> addFiles(List<String> paths) async {
    final requests = <FileScanRequest>[];
    // Rejections have to be reported, not silently dropped (AC-1.3).
    final unsupported = <String>[];

    for (final path in paths) {
      final ext = p.extension(path).toLowerCase();
      if (ext == '.jar' || ext == '.zip') {
        requests.add(
          FileScanRequest(filePath: path, kind: ext == '.jar' ? 'jar' : 'zip'),
        );
      } else {
        unsupported.add(
          '${p.basename(path)}: 지원하지 않는 확장자입니다 (.jar · .zip 만 가능).',
        );
      }
    }

    if (requests.isEmpty) {
      state = state.copyWith(rejectedSummary: unsupported);
      return;
    }
    await _processScanRequests(requests, preRejected: unsupported);
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

  /// Re-reads every input file that is still on disk (AC-2.6).
  ///
  /// Existing translations and user edits survive: entries are rebuilt key by
  /// key and anything the user touched is carried across, so only genuinely new
  /// keys come back as 대기 (AC-10.7). Files that vanished are reported rather
  /// than dropped silently (AC-10.4).
  Future<void> rescanAll() async {
    final files = await _db.select(_db.inputFiles).get();
    if (files.isEmpty) return;

    state = state.copyWith(
      isScanning: true,
      totalFiles: files.length,
      scannedFiles: 0,
      currentStatusMessage: '다시 검사하는 중…',
      rejectedSummary: const <String>[],
    );

    final cancelToken = CancellationToken();
    _scanCancelToken = cancelToken;

    final responses = await WorkerPool.scanFiles(
      [
        for (final f in files)
          FileScanRequest(filePath: f.absolutePath, kind: f.kind),
      ],
      cancelToken: cancelToken,
      onProgress: (current, total, msg) {
        state = state.copyWith(
          scannedFiles: current,
          totalFiles: total,
          currentStatusMessage: msg,
        );
      },
    );

    final notices = <String>[];
    final staleKeys = <String, List<String>>{...state.staleKeysByNamespace};
    var newNamespaceCount = 0;
    var refreshedNamespaceCount = 0;

    for (final file in files) {
      final response = responses
          .where((r) => r.filePath == file.absolutePath)
          .firstOrNull;

      if (response == null || !response.isOk) {
        notices.add(
          '${file.originalName}: ${response?.rejectReason ?? '파일을 읽을 수 없습니다.'}',
        );
        await (_db.update(
          _db.inputFiles,
        )..where((t) => t.id.equals(file.id))).write(
          InputFilesCompanion(
            scanState: Value(model.ScanState.missing.wireName),
            rejectReason: Value(response?.rejectReason ?? '파일을 읽을 수 없습니다.'),
          ),
        );
        continue;
      }

      if (response.sha256 != file.sha256) {
        notices.add('${file.originalName}: 파일이 변경되어 다시 읽었습니다.');
        await (_db.update(
          _db.inputFiles,
        )..where((t) => t.id.equals(file.id))).write(
          InputFilesCompanion(
            sha256: Value(response.sha256),
            sizeBytes: Value(response.sizeBytes),
            scanState: Value(model.ScanState.ok.wireName),
            rejectReason: const Value(null),
          ),
        );
      }

      final existing = await (_db.select(
        _db.namespaces,
      )..where((t) => t.inputFileId.equals(file.id))).get();
      final existingByName = {for (final ns in existing) ns.name: ns};

      for (final nsData in response.namespaces) {
        final known = existingByName[nsData.namespace];
        if (known == null) {
          final stale = await _insertNamespace(
            inputFileId: file.id,
            nsData: nsData,
            addedAt: DateTime.now(),
          );
          if (stale.isNotEmpty) {
            staleKeys[nsData.namespace] = stale;
          }
          newNamespaceCount++;
          continue;
        }

        final sourceData = nsData.langFiles
            .where((lf) => lf.role == 'source')
            .firstOrNull;
        if (sourceData == null) continue;

        await _replaceNamespaceEntries(
          namespaceId: known.id,
          sourceData: sourceData,
          existingTargetData: nsData.langFiles
              .where((lf) => lf.role == 'existingTarget')
              .firstOrNull,
        );
        refreshedNamespaceCount++;
      }
    }

    final conflictCount = await refreshConflicts();
    if (conflictCount > 0) {
      notices.add('충돌 $conflictCount건이 남아 있습니다.');
    }

    _scanCancelToken = null;
    state = state.copyWith(
      isScanning: false,
      currentStatusMessage:
          '다시 검사 완료 — namespace 새로 발견 $newNamespaceCount · 갱신 $refreshedNamespaceCount',
      rejectedSummary: notices,
      staleKeysByNamespace: staleKeys,
    );
    _session.markDirty();
  }

  Future<void> _processScanRequests(
    List<FileScanRequest> requests, {
    List<String> preRejected = const [],
  }) async {
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

    final rejected = <String>[...preRejected];
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

      // An untitled project takes its name from the first valid input file
      // (AC-10.9).
      _session.suggestNameFromInput(resp.originalName);

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
        final staleKeys = await _insertNamespace(
          inputFileId: inputFileId,
          nsData: ns,
          addedAt: now,
        );
        if (staleKeys.isNotEmpty) {
          staleKeysByNamespace[ns.namespace] = staleKeys;
        }
      }
    }

    final conflictCount = await refreshConflicts();
    if (conflictCount > 0) {
      rejected.add(
        '같은 namespace 의 같은 key 에 원문이 다른 항목 $conflictCount건을 충돌로 표시했습니다.',
      );
    }

    _scanCancelToken = null;
    state = state.copyWith(
      isScanning: false,
      currentStatusMessage: cancelToken.isCancelled ? '탐색을 취소했습니다.' : null,
      clearStatusMessage: !cancelToken.isCancelled,
      rejectedSummary: rejected,
      staleKeysByNamespace: staleKeysByNamespace,
    );
    _session.markDirty();
  }
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
