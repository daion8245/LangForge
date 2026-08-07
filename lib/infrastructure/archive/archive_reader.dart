// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import '../../domain/normalize/resource_path.dart';
import 'archive_guard.dart';

class DiscoveredLangFile {
  final String rawEntryPath;
  final String namespace;
  final String rawCode;
  final String contentUtf8;

  const DiscoveredLangFile({
    required this.rawEntryPath,
    required this.namespace,
    required this.rawCode,
    required this.contentUtf8,
  });
}

abstract final class ArchiveReader {
  static final Logger _log = Logger('ArchiveReader');

  /// Reads a JAR/ZIP archive using streaming input and extracts only `assets/*/lang/*.json` files.
  static Future<List<DiscoveredLangFile>> readLangFiles(
    String archivePath,
  ) async {
    final file = File(archivePath);
    if (!await file.exists()) {
      throw FileSystemException('Archive file does not exist', archivePath);
    }

    final inputStream = InputFileStream(archivePath);
    final archive = ZipDecoder().decodeStream(inputStream);
    final guard = ArchiveGuard();
    final results = <DiscoveredLangFile>[];
    final seenPaths = <String>{};

    for (final archiveFile in archive.files) {
      if (!archiveFile.isFile) continue;
      if (!ResourcePathParser.isLangResource(archiveFile.name)) continue;

      guard.validateEntry(archiveFile);

      final pathInfo = ResourcePathParser.parse(archiveFile.name);
      if (pathInfo == null) continue;

      // Compared case-insensitively: an archive built on a case-insensitive
      // file system can hold the same logical path twice. The first wins
      // (TECHNICAL.md 4.5).
      final dedupeKey = pathInfo.entryPath.toLowerCase();
      if (!seenPaths.add(dedupeKey)) {
        _log.warning(
          'Duplicate lang path in archive, ignoring: '
          '${archiveFile.name}',
        );
        continue;
      }

      final bytes = archiveFile.content as List<int>;
      final contentStr = utf8.decode(bytes);

      results.add(
        DiscoveredLangFile(
          rawEntryPath: archiveFile.name,
          namespace: pathInfo.namespace,
          rawCode: pathInfo.rawCode,
          contentUtf8: contentStr,
        ),
      );
    }

    await inputStream.close();
    return results;
  }
}
