// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/validation/pack_icon_validator.dart';

/// Where a resource pack's `pack.png` comes from.
///
/// Mirrors `ProjectMeta.packIconMode` (TECHNICAL.md 3.2 · 8.4b).
enum PackIconMode {
  /// The icon bundled with LangForge.
  bundled('default'),

  /// A PNG the user picked.
  custom('custom'),

  /// Icon extracted from an input JAR (ROADMAP 11.5).
  mod('mod'),

  /// Ship no `pack.png` at all. Minecraft accepts a pack without one.
  none('none');

  const PackIconMode(this.wireName);

  final String wireName;

  static PackIconMode fromWire(String value) {
    for (final mode in PackIconMode.values) {
      if (mode.wireName == value) return mode;
    }
    return PackIconMode.bundled;
  }
}

/// Reads the bytes for the exported `pack.png`.
abstract final class PackIconLoader {
  static const String bundledAssetPath = 'assets/pack/pack.png';

  /// Returns the icon bytes, or null when the pack should not carry an icon.
  ///
  /// A missing or unreadable custom file falls back to the bundled icon rather
  /// than failing the export — the icon is cosmetic, and losing a whole run
  /// over it would be the wrong trade.
  ///
  /// [modIconBytes] is supplied by [ModIconExtractor] when [mode] is [PackIconMode.mod].
  static Future<List<int>?> load({
    PackIconMode mode = PackIconMode.bundled,
    String? customPath,
    List<int>? modIconBytes,
  }) async {
    switch (mode) {
      case PackIconMode.none:
        return null;

      case PackIconMode.custom:
        final bytes = await _readCustom(customPath);
        if (bytes != null && PackIconValidator.validate(bytes).isValid) {
          return bytes;
        }
        return _readBundled();

      case PackIconMode.mod:
        if (modIconBytes != null &&
            PackIconValidator.validate(modIconBytes).isValid) {
          return modIconBytes;
        }
        return _readBundled();

      case PackIconMode.bundled:
        return _readBundled();
    }
  }

  static Future<List<int>?> _readCustom(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      return await file.readAsBytes();
    } on FileSystemException {
      return null;
    }
  }

  static Future<List<int>?> _readBundled() async {
    try {
      final data = await rootBundle.load(bundledAssetPath);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } on FlutterError {
      // The asset is declared in pubspec.yaml, so this only happens in a
      // broken build. Export without an icon rather than aborting.
      return null;
    }
  }
}
