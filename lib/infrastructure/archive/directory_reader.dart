// ignore_for_file: avoid_slow_async_io

import 'dart:io';
import 'package:path/path.dart' as p;
import '../../domain/normalize/resource_path.dart';
import 'archive_reader.dart';

abstract final class DirectoryReader {
  /// Recursively finds all `.jar` and `.zip` files inside a directory.
  static Future<List<File>> findArchiveFiles(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];

    final result = <File>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (ext == '.jar' || ext == '.zip') {
          result.add(entity);
        }
      }
    }
    return result;
  }

  /// Scans an unpacked folder for `assets/*/lang/*.json` files.
  static Future<List<DiscoveredLangFile>> readUnpackedFolder(
    String dirPath,
  ) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];

    final results = <DiscoveredLangFile>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final relativePath = p
            .relative(entity.path, from: dirPath)
            .replaceAll('\\', '/');
        if (ResourcePathParser.isLangResource(relativePath)) {
          final pathInfo = ResourcePathParser.parse(relativePath);
          if (pathInfo != null) {
            final contentStr = await entity.readAsString();
            results.add(
              DiscoveredLangFile(
                rawEntryPath: relativePath,
                namespace: pathInfo.namespace,
                rawCode: pathInfo.rawCode,
                contentUtf8: contentStr,
              ),
            );
          }
        }
      }
    }
    return results;
  }
}
