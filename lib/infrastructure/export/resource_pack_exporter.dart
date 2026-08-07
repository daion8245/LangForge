import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../domain/model/translation_entry.dart';
import '../../domain/policy/export_gate.dart';
import '../../domain/policy/merge_policy.dart';
import '../../domain/policy/namespace_merge.dart';
import '../../domain/validation/json_rebuilder.dart';
import 'pack_meta_builder.dart';
import 'report_exporter.dart';
import 'zip_verifier.dart';

enum ExportFormat { zipPack, folderPack, pathJson, namespaceJson, perModPacks }

/// What a write step produced: the path handed back to the caller, and the
/// files the report lists.
typedef _ExportResult = ({String path, List<ReportOutputFile> outputs});

abstract final class ResourcePackExporter {
  /// Writes the chosen output format under [targetDirPath].
  ///
  /// [outputFileName] comes from the target language profile (TECHNICAL.md
  /// 4.6) — it is never derived from the input file names.
  ///
  /// The report is written next to the pack, never inside it: TECHNICAL.md 8.1
  /// defines the pack contents exactly, and a stray `.md` does not belong in
  /// something the user ships.
  static Future<String> export({
    required String targetDirPath,
    required ExportFormat format,
    required List<InputFileUnit> inputFiles,
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    required int packFormat,
    required String providerName,
    required String modelName,
    required String sourceLangCode,
    required String targetLangCode,
    required String outputFileName,
    required String appVersion,
    Map<String, List<String>> staleKeysByNamespace = const {},
    Map<String, Map<String, String>> conflictResolutions = const {},
    List<ReportConflict> conflicts = const [],
    List<int>? packIconBytes,
    String packName = 'LangForge_Translation_Pack',
    String zipName = 'KO_Translation_Pack.zip',
  }) async {
    final tempDir = Directory.systemTemp.createTempSync('langforge_export_');

    try {
      final activeNamespaces = ExportGate.writableNamespaces(namespaces);

      // Namespaces that share a name share an output file, so they are folded
      // together before anything is written (NamespaceMerge).
      final merged = NamespaceMerge.merge(
        namespaces: activeNamespaces,
        entries: entries,
        resolutions: conflictResolutions,
      );

      final nsJsonContents = <String, String>{};
      final nsKeyCounts = <String, int>{};
      for (final ns in merged) {
        final resolvedMap = <String, String>{};
        final keyOrder = <String>[];

        for (final entry in ns.entries) {
          keyOrder.add(entry.key);
          resolvedMap[entry.key] = MergePolicy.resolveFinal(entry);
        }

        nsJsonContents[ns.name] = JsonRebuilder.rebuild(
          entries: resolvedMap,
          keyOrder: keyOrder,
        );
        nsKeyCounts[ns.name] = resolvedMap.length;
      }

      final packMetaContent = PackMetaBuilder.buildPackMeta(
        packFormat: packFormat,
        description: '$targetLangCode 번역 리소스팩 · LangForge',
      );

      final _ExportResult result;
      switch (format) {
        case ExportFormat.zipPack:
          result = await _exportZipPack(
            tempDir: tempDir,
            targetDirPath: targetDirPath,
            zipName: zipName,
            packMetaContent: packMetaContent,
            nsJsonContents: nsJsonContents,
            nsKeyCounts: nsKeyCounts,
            outputFileName: outputFileName,
            packIconBytes: packIconBytes,
          );

        case ExportFormat.folderPack:
          result = await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, packName),
            reportDirPath: targetDirPath,
            build: (stage) => [
              _writeReportedUtf8(stage.path, 'pack.mcmeta', packMetaContent),
              if (packIconBytes != null)
                _writeReportedBytes(stage.path, 'pack.png', packIconBytes),
              ..._writeNamespaceJsons(
                root: stage.path,
                nsJsonContents: nsJsonContents,
                nsKeyCounts: nsKeyCounts,
                outputFileName: outputFileName,
                underAssets: true,
              ),
            ],
          );

        case ExportFormat.pathJson:
          result = await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, 'assets'),
            reportDirPath: targetDirPath,
            build: (stage) => _writeNamespaceJsons(
              root: stage.path,
              nsJsonContents: nsJsonContents,
              nsKeyCounts: nsKeyCounts,
              outputFileName: outputFileName,
              underAssets: false,
            ),
          );

        case ExportFormat.namespaceJson:
          result = await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, 'lang_output'),
            reportDirPath: targetDirPath,
            build: (stage) => [
              for (final entry in nsJsonContents.entries)
                _writeReportedUtf8(
                  stage.path,
                  p.join(entry.key, outputFileName),
                  entry.value,
                  keyCount: nsKeyCounts[entry.key],
                ),
            ],
          );

        case ExportFormat.perModPacks:
          result = await _exportPerModPacks(
            tempDir: tempDir,
            targetDirPath: targetDirPath,
            inputFiles: inputFiles,
            namespaces: activeNamespaces,
            entries: entries,
            packMetaContent: packMetaContent,
            outputFileName: outputFileName,
            targetLangCode: targetLangCode,
            packIconBytes: packIconBytes,
            conflictResolutions: conflictResolutions,
          );
      }

      // The report is written last so its output table describes files that
      // actually exist, with the sizes they ended up having.
      final reportContent = ReportExporter.generateReport(
        inputFiles: inputFiles,
        // Every namespace, not just the writable ones — the 오류 section exists
        // to name the ones that were left out.
        namespaces: namespaces,
        entries: entries,
        providerName: providerName,
        modelName: modelName,
        sourceLangCode: sourceLangCode,
        targetLangCode: targetLangCode,
        appVersion: appVersion,
        staleKeysByNamespace: staleKeysByNamespace,
        conflicts: conflicts,
        outputFiles: result.outputs,
      );
      _writeUtf8(p.join(targetDirPath, 'Translation_Report.md'), reportContent);

      return result.path;
    } finally {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } on FileSystemException {
          // A leftover temp directory is harmless; the OS reclaims it.
        }
      }
    }
  }

  /// One ZIP per enabled input file (TECHNICAL.md 8.1 · ROADMAP 11.2).
  static Future<_ExportResult> _exportPerModPacks({
    required Directory tempDir,
    required String targetDirPath,
    required List<InputFileUnit> inputFiles,
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    required String packMetaContent,
    required String outputFileName,
    required String targetLangCode,
    required List<int>? packIconBytes,
    required Map<String, Map<String, String>> conflictResolutions,
  }) async {
    Directory(targetDirPath).createSync(recursive: true);
    final written = <String>[];
    final outputs = <ReportOutputFile>[];
    final filesById = {for (final file in inputFiles) file.id: file};

    final fileIds = <String>{
      for (final ns in namespaces) ns.inputFileId,
    }.toList()..sort();

    for (final fileId in fileIds) {
      final file = filesById[fileId];
      if (file == null) continue;
      final fileNamespaces = namespaces
          .where((ns) => ns.inputFileId == file.id)
          .toList();
      if (fileNamespaces.isEmpty) continue;

      final merged = NamespaceMerge.merge(
        namespaces: fileNamespaces,
        entries: entries,
        resolutions: conflictResolutions,
      );
      final nsJsonContents = <String, String>{};
      final nsKeyCounts = <String, int>{};
      for (final ns in merged) {
        final resolvedMap = <String, String>{};
        final keyOrder = <String>[];
        for (final entry in ns.entries) {
          keyOrder.add(entry.key);
          resolvedMap[entry.key] = MergePolicy.resolveFinal(entry);
        }
        nsJsonContents[ns.name] = JsonRebuilder.rebuild(
          entries: resolvedMap,
          keyOrder: keyOrder,
        );
        nsKeyCounts[ns.name] = resolvedMap.length;
      }
      if (nsJsonContents.isEmpty) continue;

      final stem = p.basenameWithoutExtension(file.originalName);
      final zipName = '${stem}_${targetLangCode}_Pack.zip';
      final result = await _exportZipPack(
        tempDir: tempDir,
        targetDirPath: targetDirPath,
        zipName: zipName,
        packMetaContent: packMetaContent,
        nsJsonContents: nsJsonContents,
        nsKeyCounts: nsKeyCounts,
        outputFileName: outputFileName,
        packIconBytes: packIconBytes,
      );
      written.add(result.path);
      outputs.addAll(result.outputs);
    }

    if (written.isEmpty) {
      throw StateError('내보낼 모드별 리소스팩이 없습니다');
    }
    return (
      path: written.length == 1 ? written.first : targetDirPath,
      outputs: outputs,
    );
  }

  static Future<_ExportResult> _exportZipPack({
    required Directory tempDir,
    required String targetDirPath,
    required String zipName,
    required String packMetaContent,
    required Map<String, String> nsJsonContents,
    required Map<String, int> nsKeyCounts,
    required String outputFileName,
    required List<int>? packIconBytes,
  }) async {
    final archive = Archive();
    archive.addFile(_utf8ArchiveFile('pack.mcmeta', packMetaContent));
    if (packIconBytes != null) {
      archive.addFile(
        ArchiveFile('pack.png', packIconBytes.length, packIconBytes),
      );
    }
    for (final entry in nsJsonContents.entries) {
      archive.addFile(
        _utf8ArchiveFile(
          'assets/${entry.key}/lang/$outputFileName',
          entry.value,
        ),
      );
    }

    final stagedZip = File(p.join(tempDir.path, zipName));
    stagedZip.writeAsBytesSync(ZipEncoder().encode(archive));

    // Open the file we just wrote and check it before anything is moved.
    await ZipVerifier.verifyPackZip(
      stagedZip.path,
      expectIcon: packIconBytes != null,
    );

    final finalPath = p.join(targetDirPath, zipName);
    Directory(targetDirPath).createSync(recursive: true);
    _replaceAtomically(stagedZip, File(finalPath));

    final totalKeys = nsKeyCounts.values.fold(0, (sum, count) => sum + count);
    return (
      path: finalPath,
      outputs: [
        ReportOutputFile(
          path: zipName,
          sizeBytes: File(finalPath).lengthSync(),
          keyCount: totalKeys,
        ),
      ],
    );
  }

  /// Builds the whole tree in a staging directory, then swaps it into place.
  /// A failure inside [build] leaves the target untouched (TECHNICAL.md 8.5).
  ///
  /// [build] reports the files it wrote as paths relative to the staging root;
  /// they are rebased onto [reportDirPath] for the report.
  static Future<_ExportResult> _exportStagedTree({
    required Directory tempDir,
    required String targetPath,
    required String reportDirPath,
    required List<ReportOutputFile> Function(Directory stage) build,
  }) async {
    final stage = Directory(p.join(tempDir.path, 'stage'))
      ..createSync(recursive: true);

    final staged = build(stage);

    Directory(p.dirname(targetPath)).createSync(recursive: true);

    final target = Directory(targetPath);
    Directory? backup;
    if (target.existsSync()) {
      backup = Directory('${targetPath}_bak');
      if (backup.existsSync()) backup.deleteSync(recursive: true);
      target.renameSync(backup.path);
    }

    try {
      // Same-volume rename when possible; copy is the cross-volume fallback.
      try {
        stage.renameSync(targetPath);
      } on FileSystemException {
        _copyDirectorySync(stage, target);
      }
    } catch (_) {
      // Put the user's previous output back before giving up.
      if (backup != null && backup.existsSync()) {
        if (target.existsSync()) target.deleteSync(recursive: true);
        backup.renameSync(targetPath);
      }
      rethrow;
    }

    final prefix = p.relative(targetPath, from: reportDirPath);
    return (
      path: targetPath,
      outputs: [
        for (final file in staged)
          ReportOutputFile(
            path: p.join(prefix, file.path).replaceAll(r'\', '/'),
            sizeBytes: file.sizeBytes,
            keyCount: file.keyCount,
          ),
      ],
    );
  }

  static List<ReportOutputFile> _writeNamespaceJsons({
    required String root,
    required Map<String, String> nsJsonContents,
    required Map<String, int> nsKeyCounts,
    required String outputFileName,
    required bool underAssets,
  }) {
    final written = <ReportOutputFile>[];
    for (final entry in nsJsonContents.entries) {
      final relative = underAssets
          ? p.join('assets', entry.key, 'lang', outputFileName)
          : p.join(entry.key, 'lang', outputFileName);
      written.add(
        _writeReportedUtf8(
          root,
          relative,
          entry.value,
          keyCount: nsKeyCounts[entry.key],
        ),
      );
    }
    return written;
  }

  /// Writes [relativePath] under [root], creating parents, and describes the
  /// result for the report's output table.
  static ReportOutputFile _writeReportedUtf8(
    String root,
    String relativePath,
    String content, {
    int? keyCount,
  }) {
    final bytes = utf8.encode(content);
    _writeBytes(p.join(root, relativePath), bytes);
    return ReportOutputFile(
      path: relativePath.replaceAll(r'\', '/'),
      sizeBytes: bytes.length,
      keyCount: keyCount,
    );
  }

  static ReportOutputFile _writeReportedBytes(
    String root,
    String relativePath,
    List<int> bytes,
  ) {
    _writeBytes(p.join(root, relativePath), bytes);
    return ReportOutputFile(
      path: relativePath.replaceAll(r'\', '/'),
      sizeBytes: bytes.length,
    );
  }

  /// `String.codeUnits` yields UTF-16 units, so every non-Latin character is
  /// silently mangled on the way into a byte sink. Everything this class
  /// writes goes through UTF-8 encoding instead.
  static ArchiveFile _utf8ArchiveFile(String path, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(path, bytes.length, bytes);
  }

  static void _writeUtf8(String path, String content) {
    _writeBytes(path, utf8.encode(content));
  }

  static void _writeBytes(String path, List<int> bytes) {
    Directory(p.dirname(path)).createSync(recursive: true);
    File(path).writeAsBytesSync(bytes);
  }

  static void _replaceAtomically(File staged, File target) {
    if (target.existsSync()) {
      final backup = File('${target.path}.bak');
      if (backup.existsSync()) backup.deleteSync();
      target.renameSync(backup.path);
    }
    try {
      staged.renameSync(target.path);
    } on FileSystemException {
      staged.copySync(target.path);
    }
  }

  static void _copyDirectorySync(Directory source, Directory destination) {
    destination.createSync(recursive: true);
    for (final entity in source.listSync()) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        _copyDirectorySync(entity, Directory(newPath));
      } else if (entity is File) {
        entity.copySync(newPath);
      }
    }
  }
}
