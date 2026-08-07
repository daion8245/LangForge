import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../project/project_paths.dart';
import 'app_platform.dart';
import 'memory_budget.dart';

/// What one "add files" gesture produced.
class ImportSelection {
  const ImportSelection({
    this.paths = const [],
    this.totalBytes = 0,
    this.rejected = const [],
  });

  static const ImportSelection empty = ImportSelection();

  /// Absolute paths that survived the size checks, ready for `addFiles`.
  final List<String> paths;

  final int totalBytes;

  /// One line per refused file, already worded for the user. Never empty when
  /// something was dropped — a file that disappears without a reason is the
  /// failure mode this list exists to prevent.
  final List<String> rejected;

  bool get isEmpty => paths.isEmpty && rejected.isEmpty;
}

/// The one place that knows how each host hands files to the app.
///
/// Desktop works in absolute paths. Android has no `.minecraft` to point at and
/// no writable path outside the sandbox, so the picker copies whatever the user
/// chose into the app cache and hands back a real path (MOBILE.md 1.1). That is
/// what lets the scan pipeline stay platform-blind: nothing below this file has
/// ever seen a `content://` URI.
abstract final class FileAccess {
  /// Adding a whole `mods` folder. Android returns a document *tree* URI that
  /// `dart:io` cannot open, so folder import is desktop-only (MOBILE.md 1.1).
  static bool get supportsFolderImport => !AppPlatform.isMobile;

  /// Re-reading the original archives. On Android they were cache copies that
  /// [releaseImportCache] already deleted, so there is nothing to re-read
  /// (MOBILE.md 1.4).
  static bool get supportsRescan => !AppPlatform.isMobile;

  /// Writing many files into a chosen directory. Android can only be handed a
  /// single `ACTION_CREATE_DOCUMENT` sink, so only the single-ZIP format is
  /// offered there (MOBILE.md 1.1).
  static bool get supportsDirectoryExport => !AppPlatform.isMobile;

  /// Everything a single import may add up to on a phone.
  static const int mobileImportBatchLimitBytes = 256 * 1024 * 1024;

  /// Picks input archives.
  ///
  /// `withData: false` matters on both hosts: the bytes are read by the scan
  /// isolate straight off disk, and loading a 128MB JAR into the UI isolate
  /// first is exactly the allocation MemoryBudget exists to avoid.
  static Future<ImportSelection> pickInputFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jar', 'zip'],
      withData: false,
    );
    if (result == null) return ImportSelection.empty;

    final paths = <String>[];
    final rejected = <String>[];
    var total = 0;

    for (final file in result.files) {
      final path = file.path;
      if (path == null) {
        rejected.add('${file.name} — 파일 경로를 얻지 못했습니다.');
        continue;
      }
      if (file.size > MemoryBudget.maxInputFileBytes) {
        rejected.add(
          '${file.name} — 파일 크기가 상한(${_mb(MemoryBudget.maxInputFileBytes)}MB)을 초과합니다.',
        );
        continue;
      }
      if (AppPlatform.isMobile &&
          total + file.size > mobileImportBatchLimitBytes) {
        rejected.add(
          '${file.name} — 한 번에 가져올 수 있는 합계(${_mb(mobileImportBatchLimitBytes)}MB)를 초과합니다. '
          '나눠서 추가하세요.',
        );
        continue;
      }
      paths.add(path);
      total += file.size;
    }

    return ImportSelection(paths: paths, totalBytes: total, rejected: rejected);
  }

  /// Drops the picker's cached copies once the scan has moved everything it
  /// needs into the database (MOBILE.md 1.4).
  ///
  /// Desktop paths point at the user's own files, so there is nothing to clear
  /// and calling this would be a no-op at best.
  static Future<void> releaseImportCache() async {
    if (!AppPlatform.isMobile) return;
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (_) {
      // Freeing cache is an optimization; failing to free it is not an error
      // the user can act on.
    }
  }

  static Future<String?> pickProjectFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['lfproj'],
      withData: false,
    );
    return result?.paths.whereType<String>().firstOrNull;
  }

  /// Where a project is saved when the user is not asked for a location.
  ///
  /// Android has no "choose any folder" save, so a project always lands in the
  /// app's own documents directory under its own name.
  static Future<String> defaultProjectPath(String projectName) async {
    final dir = await ProjectPaths.defaultProjectsDirectoryPath();
    final safe = sanitizeFileName(projectName);
    return p.join(dir, '$safe${ProjectPaths.projectExtension}');
  }

  /// Writes an export to a location the user picks.
  ///
  /// Returns the path it landed on, or null if the user backed out. On Android
  /// this is `ACTION_CREATE_DOCUMENT`; the bytes are handed to the platform
  /// because the app cannot open the chosen URI itself.
  static Future<String?> saveExportBytes({
    required String fileName,
    required List<int> bytes,
  }) {
    return FilePicker.saveFile(
      dialogTitle: '내보낼 위치 선택',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [p.extension(fileName).replaceFirst('.', '')],
      bytes: Uint8List.fromList(bytes),
    );
  }

  /// Turns a storage failure into something the user can act on.
  ///
  /// A raw `SqliteException: disk I/O error` tells nobody to delete a video
  /// (MOBILE.md 1.4).
  static String describeStorageError(Object error) {
    final text = error.toString().toLowerCase();
    final outOfSpace =
        text.contains('no space') ||
        text.contains('enospc') ||
        text.contains('disk is full') ||
        text.contains('database or disk is full');
    if (outOfSpace) {
      return '저장 공간이 부족합니다. 공간을 확보한 뒤 다시 시도하세요.';
    }
    if (text.contains('permission') || text.contains('eacces')) {
      return '파일에 접근할 권한이 없습니다. 파일을 다시 선택해 주세요.';
    }
    return '저장하지 못했습니다: $error';
  }

  /// Strips what no host accepts in a file name.
  static String sanitizeFileName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'LangForge';
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static int _mb(int bytes) => bytes ~/ (1024 * 1024);
}
