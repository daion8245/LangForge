// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../domain/validation/pack_icon_validator.dart';
import '../security/sensitive_filter.dart';

/// Pulls a pack icon out of a mod JAR/ZIP (TECHNICAL.md 8.4b · ROADMAP 11.5).
///
/// Search order: `pack.png`, `icon.png`, `logo.png`, then `logoFile` from
/// `META-INF/mods.toml`, then `icon` from `fabric.mod.json`. The first image
/// that passes [PackIconValidator] wins. Non-square / out-of-range images are
/// skipped rather than cropped here — without a dedicated image codec the safe
/// fallthrough is the bundled default.
abstract final class ModIconExtractor {
  static final Logger _log = Logger('ModIconExtractor');

  static const _directNames = ['pack.png', 'icon.png', 'logo.png'];

  /// Returns validated PNG bytes, or null when nothing usable was found.
  static Future<List<int>?> extractFromFiles(Iterable<String> paths) async {
    for (final path in paths) {
      final bytes = await extractFromPath(path);
      if (bytes != null) return bytes;
    }
    return null;
  }

  static Future<List<int>?> extractFromPath(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final lower = path.toLowerCase();
    if (lower.endsWith('.jar') || lower.endsWith('.zip')) {
      return _fromArchive(file);
    }
    if (await FileSystemEntity.isDirectory(path)) {
      return _fromDirectory(Directory(path));
    }
    return null;
  }

  static Future<List<int>?> _fromArchive(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes, verify: false);
      final byName = <String, ArchiveFile>{
        for (final entry in archive.files)
          if (entry.isFile)
            entry.name.replaceAll('\\', '/').toLowerCase(): entry,
      };

      for (final name in _directNames) {
        final hit = _takeValid(byName[name]);
        if (hit != null) return hit;
      }

      final modsToml = byName['meta-inf/mods.toml'];
      if (modsToml != null) {
        final logo = _logoFromModsToml(
          utf8.decode(modsToml.content as List<int>, allowMalformed: true),
        );
        if (logo != null) {
          final hit = _takeValid(byName[logo.toLowerCase()]);
          if (hit != null) return hit;
        }
      }

      final fabric = byName['fabric.mod.json'];
      if (fabric != null) {
        final icon = _iconFromFabric(
          utf8.decode(fabric.content as List<int>, allowMalformed: true),
        );
        if (icon != null) {
          final hit = _takeValid(byName[icon.toLowerCase()]);
          if (hit != null) return hit;
        }
      }
    } on FormatException catch (error, stack) {
      _log.warning(
        SensitiveFilter.scrub('Could not read archive icon: $error'),
        error,
        stack,
      );
    } on FileSystemException catch (error, stack) {
      _log.warning(
        SensitiveFilter.scrub('Could not open archive for icon: $error'),
        error,
        stack,
      );
    }
    return null;
  }

  static Future<List<int>?> _fromDirectory(Directory dir) async {
    for (final name in _directNames) {
      final file = File(p.join(dir.path, name));
      if (await file.exists()) {
        final hit = PackIconValidator.validate(await file.readAsBytes());
        if (hit.isValid) return await file.readAsBytes();
      }
    }
    return null;
  }

  static List<int>? _takeValid(ArchiveFile? entry) {
    if (entry == null) return null;
    final bytes = List<int>.from(entry.content);
    return PackIconValidator.validate(bytes).isValid ? bytes : null;
  }

  static String? _logoFromModsToml(String text) {
    final match = RegExp(
      r'''logoFile\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(1);
  }

  static String? _iconFromFabric(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map) return null;
      final icon = decoded['icon'];
      if (icon is String && icon.isNotEmpty) return icon;
      if (icon is Map && icon.isNotEmpty) {
        final first = icon.values.whereType<String>().firstOrNull;
        return first;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
