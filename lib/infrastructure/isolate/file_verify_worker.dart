// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:crypto/crypto.dart';

/// One input file to re-check when a project is opened.
class FileVerifyRequest {
  const FileVerifyRequest({
    required this.inputFileId,
    required this.absolutePath,
    required this.expectedSha256,
  });

  final String inputFileId;
  final String absolutePath;
  final String expectedSha256;
}

class FileVerifyResult {
  const FileVerifyResult({
    required this.inputFileId,
    required this.exists,
    this.sha256,
    this.sizeBytes = 0,
  });

  final String inputFileId;
  final bool exists;

  /// Null when the file is gone.
  final String? sha256;

  final int sizeBytes;
}

/// Re-hashes one input file. Runs on a worker isolate: 180 JARs of up to
/// 512 MB must never be hashed on the UI thread (AGENTS.md 2.3).
Future<FileVerifyResult> verifyInputFileInIsolate(
  FileVerifyRequest request,
) async {
  final file = File(request.absolutePath);
  if (!await file.exists()) {
    return FileVerifyResult(inputFileId: request.inputFileId, exists: false);
  }

  final sink = _DigestSink();
  final converter = sha256.startChunkedConversion(sink);
  await for (final chunk in file.openRead()) {
    converter.add(chunk);
  }
  converter.close();

  return FileVerifyResult(
    inputFileId: request.inputFileId,
    exists: true,
    sha256: sink.digest.toString(),
    sizeBytes: await file.length(),
  );
}

class _DigestSink implements Sink<Digest> {
  late Digest digest;

  @override
  void add(Digest data) => digest = data;

  @override
  void close() {}
}
