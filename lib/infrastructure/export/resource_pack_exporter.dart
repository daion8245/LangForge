import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../../domain/model/translation_entry.dart';
import '../../domain/policy/export_gate.dart';
import '../../domain/policy/merge_policy.dart';
import '../../domain/validation/json_rebuilder.dart';
import 'pack_meta_builder.dart';
import 'report_exporter.dart';
import 'zip_verifier.dart';

enum ExportFormat { zipPack, folderPack, pathJson, namespaceJson }

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
    List<int>? packIconBytes,
    String packName = 'LangForge_Translation_Pack',
    String zipName = 'KO_Translation_Pack.zip',
  }) async {
    final tempDir = Directory.systemTemp.createTempSync('langforge_export_');

    try {
      final activeNamespaces = ExportGate.writableNamespaces(namespaces);

      final nsJsonContents = <String, String>{};
      for (final ns in activeNamespaces) {
        final nsEntries = entries.where((e) => e.namespaceId == ns.id).toList()
          ..sort((a, b) => a.keyOrder.compareTo(b.keyOrder));

        final resolvedMap = <String, String>{};
        final keyOrder = <String>[];

        for (final entry in nsEntries) {
          keyOrder.add(entry.key);
          resolvedMap[entry.key] = MergePolicy.resolveFinal(entry);
        }

        nsJsonContents[ns.name] = JsonRebuilder.rebuild(
          entries: resolvedMap,
          keyOrder: keyOrder,
        );
      }

      final packMetaContent = PackMetaBuilder.buildPackMeta(
        packFormat: packFormat,
      );

      final reportContent = ReportExporter.generateReport(
        inputFiles: inputFiles,
        namespaces: activeNamespaces,
        entries: entries,
        providerName: providerName,
        modelName: modelName,
        sourceLangCode: sourceLangCode,
        targetLangCode: targetLangCode,
        appVersion: appVersion,
        staleKeysByNamespace: staleKeysByNamespace,
      );

      switch (format) {
        case ExportFormat.zipPack:
          return await _exportZipPack(
            tempDir: tempDir,
            targetDirPath: targetDirPath,
            zipName: zipName,
            packMetaContent: packMetaContent,
            reportContent: reportContent,
            nsJsonContents: nsJsonContents,
            outputFileName: outputFileName,
            packIconBytes: packIconBytes,
          );

        case ExportFormat.folderPack:
          return await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, packName),
            reportContent: reportContent,
            reportDirPath: targetDirPath,
            build: (stage) {
              _writeUtf8(p.join(stage.path, 'pack.mcmeta'), packMetaContent);
              if (packIconBytes != null) {
                File(
                  p.join(stage.path, 'pack.png'),
                ).writeAsBytesSync(packIconBytes);
              }
              _writeNamespaceJsons(
                root: stage.path,
                nsJsonContents: nsJsonContents,
                outputFileName: outputFileName,
                underAssets: true,
              );
            },
          );

        case ExportFormat.pathJson:
          return await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, 'assets'),
            reportContent: reportContent,
            reportDirPath: targetDirPath,
            build: (stage) {
              _writeNamespaceJsons(
                root: stage.path,
                nsJsonContents: nsJsonContents,
                outputFileName: outputFileName,
                underAssets: false,
              );
            },
          );

        case ExportFormat.namespaceJson:
          return await _exportStagedTree(
            tempDir: tempDir,
            targetPath: p.join(targetDirPath, 'lang_output'),
            reportContent: reportContent,
            reportDirPath: targetDirPath,
            build: (stage) {
              for (final entry in nsJsonContents.entries) {
                final nsDir = Directory(p.join(stage.path, entry.key))
                  ..createSync(recursive: true);
                _writeUtf8(p.join(nsDir.path, outputFileName), entry.value);
              }
            },
          );
      }
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

  static Future<String> _exportZipPack({
    required Directory tempDir,
    required String targetDirPath,
    required String zipName,
    required String packMetaContent,
    required String reportContent,
    required Map<String, String> nsJsonContents,
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

    _writeUtf8(p.join(targetDirPath, 'Translation_Report.md'), reportContent);
    return finalPath;
  }

  /// Builds the whole tree in a staging directory, then swaps it into place.
  /// A failure inside [build] leaves the target untouched (TECHNICAL.md 8.5).
  static Future<String> _exportStagedTree({
    required Directory tempDir,
    required String targetPath,
    required String reportContent,
    required String reportDirPath,
    required void Function(Directory stage) build,
  }) async {
    final stage = Directory(p.join(tempDir.path, 'stage'))
      ..createSync(recursive: true);

    build(stage);

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

    _writeUtf8(p.join(reportDirPath, 'Translation_Report.md'), reportContent);
    return targetPath;
  }

  static void _writeNamespaceJsons({
    required String root,
    required Map<String, String> nsJsonContents,
    required String outputFileName,
    required bool underAssets,
  }) {
    for (final entry in nsJsonContents.entries) {
      final langDir = Directory(
        underAssets
            ? p.join(root, 'assets', entry.key, 'lang')
            : p.join(root, entry.key, 'lang'),
      )..createSync(recursive: true);
      _writeUtf8(p.join(langDir.path, outputFileName), entry.value);
    }
  }

  /// `String.codeUnits` yields UTF-16 units, so every non-Latin character is
  /// silently mangled on the way into a byte sink. Everything this class
  /// writes goes through UTF-8 encoding instead.
  static ArchiveFile _utf8ArchiveFile(String path, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(path, bytes.length, bytes);
  }

  static void _writeUtf8(String path, String content) {
    File(path).writeAsBytesSync(utf8.encode(content));
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
