// ignore_for_file: avoid_slow_async_io

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../domain/normalize/language_code.dart';
import '../../domain/validation/json_precheck.dart';
import '../archive/archive_guard.dart';
import '../archive/archive_reader.dart';
import '../archive/directory_reader.dart';
import 'messages.dart';

/// Hashes [file] in chunks.
///
/// The size limit allows 512 MB inputs, and reading one of those into memory
/// to hash it would defeat the streaming reader (AGENTS.md 5.6).
Future<String> _hashFile(File file) async {
  final sink = _DigestSink();
  final input = sha256.startChunkedConversion(sink);
  await for (final chunk in file.openRead()) {
    input.add(chunk);
  }
  input.close();
  return sink.digest.toString();
}

/// Captures the single digest a chunked hash conversion emits.
class _DigestSink implements Sink<Digest> {
  late Digest digest;

  @override
  void add(Digest data) => digest = data;

  @override
  void close() {}
}

Future<FileScanResponse> scanFileInIsolate(FileScanRequest request) async {
  final file = File(request.filePath);
  final isDir = request.kind == 'directory';

  if (!isDir && !await file.exists()) {
    return FileScanResponse(
      filePath: request.filePath,
      originalName: p.basename(request.filePath),
      sizeBytes: 0,
      sha256: '',
      isOk: false,
      rejectReason: '파일이 존재하지 않습니다.',
    );
  }

  // 1. Calculate SHA-256 hash & size
  String sha256Hash = '';
  int sizeBytes = 0;

  if (isDir) {
    // A folder has no bytes of its own. Its identity is its path, hashed the
    // same way so the value fits the sha256 column and the unique index.
    sizeBytes = 0;
    sha256Hash = sha256.convert(utf8.encode(request.filePath)).toString();
  } else {
    sizeBytes = await file.length();
    if (sizeBytes > ArchiveLimits.maxInputFileBytes) {
      return FileScanResponse(
        filePath: request.filePath,
        originalName: p.basename(request.filePath),
        sizeBytes: sizeBytes,
        sha256: '',
        isOk: false,
        rejectReason:
            '파일 크기가 상한(${ArchiveLimits.maxInputFileBytes ~/ (1024 * 1024)}MB)을 초과합니다.',
      );
    }
    sha256Hash = await _hashFile(file);
  }

  // 2. Extract discovered lang files
  List<DiscoveredLangFile> discovered;
  try {
    if (isDir) {
      discovered = await DirectoryReader.readUnpackedFolder(request.filePath);
    } else {
      discovered = await ArchiveReader.readLangFiles(request.filePath);
    }
  } catch (e) {
    return FileScanResponse(
      filePath: request.filePath,
      originalName: p.basename(request.filePath),
      sizeBytes: sizeBytes,
      sha256: sha256Hash,
      isOk: false,
      rejectReason: '압축 파일 읽기 실패: ${e.toString()}',
    );
  }

  if (discovered.isEmpty) {
    return FileScanResponse(
      filePath: request.filePath,
      originalName: p.basename(request.filePath),
      sizeBytes: sizeBytes,
      sha256: sha256Hash,
      isOk: false,
      rejectReason: 'assets/*/lang/*.json 언어 파일을 찾을 수 없습니다.',
    );
  }

  // 3. Group by namespace
  final nsMap = <String, List<DiscoveredLangFile>>{};
  for (final langFile in discovered) {
    nsMap.putIfAbsent(langFile.namespace, () => []).add(langFile);
  }

  final namespaceDataList = <DiscoveredNamespaceData>[];

  for (final nsEntry in nsMap.entries) {
    final nsName = nsEntry.key;
    final files = nsEntry.value;

    String nsState = 'ok';
    String? nsError;
    int? nsErrorLine;

    final langFileDataList = <DiscoveredLangFileData>[];

    // Find source language file (default: en_us)
    DiscoveredLangFile? sourceFile;
    for (final f in files) {
      final normalized = LanguageCodeNormalizer.normalize(f.rawCode);
      if (normalized == 'en_us') {
        sourceFile = f;
        break;
      }
    }

    if (sourceFile == null && files.isNotEmpty) {
      nsState = 'noSource';
    }

    for (final f in files) {
      final normalizedCode = LanguageCodeNormalizer.normalize(f.rawCode);
      final checkResult = JsonPrecheck.check(f.contentUtf8);

      if (!checkResult.isValid) {
        nsState = 'jsonError';
        nsError = checkResult.errorMessage;
        nsErrorLine = checkResult.errorLine;
      }

      String role = 'other';
      if (sourceFile != null && f.rawEntryPath == sourceFile.rawEntryPath) {
        role = 'source';
      } else if (normalizedCode == 'ko_kr') {
        role = 'existingTarget';
      }

      langFileDataList.add(
        DiscoveredLangFileData(
          rawCode: f.rawCode,
          code: normalizedCode,
          entryPath: f.rawEntryPath,
          keyCount: checkResult.entries.length,
          role: role,
          entries: checkResult.entries,
          keyOrder: checkResult.keyOrder,
        ),
      );
    }

    namespaceDataList.add(
      DiscoveredNamespaceData(
        namespace: nsName,
        state: nsState,
        errorMessage: nsError,
        errorLine: nsErrorLine,
        langFiles: langFileDataList,
      ),
    );
  }

  return FileScanResponse(
    filePath: request.filePath,
    originalName: p.basename(request.filePath),
    sizeBytes: sizeBytes,
    sha256: sha256Hash,
    isOk: true,
    namespaces: namespaceDataList,
  );
}
