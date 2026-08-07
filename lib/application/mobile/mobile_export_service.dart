import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/policy/export_gate.dart';
import '../../domain/validation/pack_icon_validator.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/db/row_mappers.dart';
import '../../infrastructure/export/mod_icon_extractor.dart';
import '../../infrastructure/export/pack_icon_loader.dart';
import '../../infrastructure/export/pack_meta_builder.dart';
import '../../infrastructure/export/resource_pack_exporter.dart';
import '../../infrastructure/platform/file_access.dart';
import '../cache/cache_providers.dart';
import '../db_provider.dart';
import '../merge/merge_hydrator.dart';
import '../project/project_language_pair.dart';
import '../scan/scan_controller.dart';
import '../settings/engine_settings.dart';
import '../translation/translation_controller.dart';

/// Where an export ended up, or why it did not happen.
sealed class MobileExportOutcome {}

final class MobileExportSaved extends MobileExportOutcome {
  MobileExportSaved(this.path);

  final String path;
}

/// The user backed out of the system save sheet. Not an error.
final class MobileExportCancelled extends MobileExportOutcome {}

final class MobileExportFailed extends MobileExportOutcome {
  MobileExportFailed(this.message);

  final String message;
}

/// Runs an export on a phone.
///
/// Android cannot hand the app a writable directory (MOBILE.md 1.1), so the
/// pack is built into an app-private staging directory first and the finished
/// bytes are handed to `ACTION_CREATE_DOCUMENT`. Everything between those two
/// steps is the same [ResourcePackExporter] the desktop uses — including the
/// report and the ZIP verification, which is the point of staging rather than
/// zipping something bespoke here.
class MobileExportService {
  const MobileExportService(this.ref);

  final Ref ref;

  /// The only format a phone offers (MOBILE.md 1.1). The other four write
  /// several files into a directory, which SAF does not give the app.
  static const ExportFormat format = ExportFormat.zipPack;

  Future<MobileExportOutcome> exportZipPack({
    required String mcVersion,
    required String appVersion,
  }) async {
    final db = ref.read(appDatabaseProvider);

    if (ref.read(translationControllerProvider).isActive) {
      return MobileExportFailed('번역이 진행 중입니다. 완료 또는 취소 후 내보낼 수 있습니다.');
    }

    Directory? staging;
    try {
      final langs = await ProjectLanguagePair.fromDb(db);
      final engine = ref.read(engineSettingsProvider);
      final meta = await db.select(db.projectMeta).getSingleOrNull();
      final inputFiles = await db.select(db.inputFiles).get();
      final namespaces = (await db.select(db.namespaces).get()).toDomain();

      // Export is the one operation that legitimately needs every row — the
      // output file is the whole project by definition.
      final entryRows = await db.select(db.entries).get();
      final hydrator = MergeHydrator(
        db: db,
        cacheStore: ref.read(translationCacheStoreProvider),
        glossaryStore: ref.read(glossaryStoreProvider),
        sourceLang: langs.sourceLang,
        targetLang: langs.targetLang,
        providerId: engine.providerId,
        modelId: engine.model,
      );
      final entries = await hydrator.hydrateAll(entryRows);

      final resolvedRows = await (db.select(
        db.conflicts,
      )..where((t) => t.resolved.equals(true))).get();
      final conflictResolutions = <String, Map<String, String>>{};
      for (final row in resolvedRows) {
        final entryId = row.resolvedEntryId;
        if (entryId == null) continue;
        conflictResolutions.putIfAbsent(row.namespaceName, () => {})[row.key] =
            entryId;
      }

      final mcVersionsJson = await rootBundle.loadString(
        'assets/data/mc_versions.json',
      );
      final packFormat = PackMetaBuilder.getPackFormat(
        mcVersionsJson,
        mcVersion,
      );

      final zipName = '${langs.targetLang.toUpperCase()}_Translation_Pack.zip';

      staging = await _freshStagingDirectory();
      final producedPath = await ResourcePackExporter.export(
        targetDirPath: staging.path,
        format: format,
        inputFiles: inputFiles.toDomain(),
        namespaces: namespaces,
        entries: entries,
        packFormat: packFormat,
        providerName: engine.provider.displayName,
        modelName: engine.model,
        sourceLangCode: langs.sourceLang,
        targetLangCode: langs.targetLang,
        outputFileName: langs.outputFileName,
        appVersion: appVersion,
        staleKeysByNamespace: ref
            .read(scanControllerProvider)
            .staleKeysByNamespace,
        conflictResolutions: conflictResolutions,
        packIconBytes: await _packIcon(meta, inputFiles),
        zipName: zipName,
      );

      final bytes = await File(producedPath).readAsBytes();
      final saved = await FileAccess.saveExportBytes(
        fileName: p.basename(producedPath),
        bytes: bytes,
      );
      if (saved == null) return MobileExportCancelled();
      return MobileExportSaved(saved);
    } catch (error) {
      return MobileExportFailed(FileAccess.describeStorageError(error));
    } finally {
      // The staged copy is a second full copy of the pack. On a phone that is
      // exactly the kind of leftover MOBILE.md 1.4 is about.
      if (staging != null && staging.existsSync()) {
        try {
          staging.deleteSync(recursive: true);
        } catch (_) {
          // Best effort; the OS clears the cache directory on its own.
        }
      }
    }
  }

  Future<Directory> _freshStagingDirectory() async {
    final base = await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'langforge_export_staging'));
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    return dir;
  }

  /// Cosmetic only — never throws into the export path (TECHNICAL.md 8.4b).
  ///
  /// `원본 모드 아이콘` cannot work on Android: the JARs it would read were
  /// cache copies that the scan already released (MOBILE.md 1.4), so it falls
  /// through to the bundled icon like any other extraction failure.
  Future<List<int>?> _packIcon(
    ProjectMetaData? meta,
    List<InputFile> inputFiles,
  ) async {
    final mode = PackIconMode.fromWire(meta?.packIconMode ?? 'default');
    switch (mode) {
      case PackIconMode.none:
        return null;
      case PackIconMode.custom:
        final loaded = await PackIconLoader.load(
          mode: PackIconMode.custom,
          customPath: meta?.packIconPath,
        );
        if (loaded == null) return PackIconLoader.load();
        if (!PackIconValidator.validate(loaded).isValid) {
          return PackIconLoader.load();
        }
        return loaded;
      case PackIconMode.mod:
        final extracted = await ModIconExtractor.extractFromFiles(
          inputFiles.map((f) => f.absolutePath),
        );
        return extracted ?? await PackIconLoader.load();
      case PackIconMode.bundled:
        return PackIconLoader.load();
    }
  }
}

final mobileExportServiceProvider = Provider<MobileExportService>(
  MobileExportService.new,
);

/// Whether the export gate lets this project out, computed from SQL counts.
///
/// Deliberately not [ExportGate.evaluate]: that one needs every entry in
/// memory, and the 출력 tab is on screen the whole time (MOBILE.md 1.2).
ExportVerdict mobileExportVerdict({
  required int activeNamespaceCount,
  required int jsonErrorNamespaceCount,
  required ExportSummary summary,
  required bool isTranslating,
  required bool hasUnresolvedConflict,
  required ExportPolicyOptions options,
}) {
  return ExportGate.evaluateAggregate(
    activeNamespaceCount: activeNamespaceCount,
    jsonErrorNamespaceCount: jsonErrorNamespaceCount,
    summary: summary,
    isTranslating: isTranslating,
    hasUnresolvedConflict: hasUnresolvedConflict,
    options: options,
  );
}
