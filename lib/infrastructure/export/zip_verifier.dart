import 'dart:io';

import 'package:archive/archive.dart';

class ExportError implements Exception {
  const ExportError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Opens a freshly written pack and checks it, because a structurally wrong
/// pack fails silently in Minecraft. See TECHNICAL.md 8.2.
abstract final class ZipVerifier {
  /// `assets/{namespace}/lang/{file}` and nothing deeper.
  static final RegExp _langEntry = RegExp(
    r'^assets/[A-Za-z0-9._-]+/lang/[A-Za-z0-9_.-]+\.json$',
  );

  static Future<void> verifyPackZip(
    String zipPath, {
    bool expectIcon = false,
  }) async {
    final file = File(zipPath);
    if (!file.existsSync()) {
      throw const ExportError('생성된 ZIP 파일을 찾을 수 없습니다.');
    }

    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    final names = archive.files
        .where((f) => f.isFile)
        .map((f) => f.name)
        .toList();

    if (!names.contains('pack.mcmeta')) {
      throw const ExportError('pack.mcmeta 가 ZIP 최상단에 없습니다.');
    }

    if (names.any((n) => n.endsWith('/pack.mcmeta') && n != 'pack.mcmeta')) {
      throw const ExportError('pack.mcmeta 가 하위 폴더에 있습니다. 최상단에 배치해야 합니다.');
    }

    // Windows tooling produces backslashes; the ZIP spec and Minecraft both
    // require forward slashes.
    if (names.any((n) => n.contains('\\'))) {
      throw const ExportError('ZIP 경로에 역슬래시가 포함되었습니다. 항상 / 를 사용해야 합니다.');
    }

    if (expectIcon && !names.contains('pack.png')) {
      throw const ExportError('pack.png 가 ZIP 최상단에 없습니다.');
    }

    if (names.any((n) => n.endsWith('/pack.png') && n != 'pack.png')) {
      throw const ExportError('pack.png 가 하위 폴더에 있습니다. 최상단에 배치해야 합니다.');
    }

    final langFiles = names.where((n) => n.startsWith('assets/')).toList();
    if (langFiles.isEmpty) {
      throw const ExportError('언어 파일이 하나도 없습니다.');
    }

    for (final name in langFiles) {
      if (!_langEntry.hasMatch(name)) {
        throw ExportError(
          'assets/{namespace}/lang/{파일}.json 형태가 아닌 항목이 있습니다: $name',
        );
      }
    }
  }
}
