// ignore_for_file: avoid_slow_async_io

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../security/sensitive_filter.dart';

/// Writes scrubbed log records to `%APPDATA%\LangForge\logs\langforge.log`
/// and rotates them. See TECHNICAL.md 13.1.
class FileLogger {
  FileLogger._();

  static final FileLogger instance = FileLogger._();

  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Total files kept: `langforge.log` plus `langforge.1.log` … up to this
  /// count. TECHNICAL.md 13.1 caps the directory at 5 files.
  static const int maxFiles = 5;

  static const String _baseName = 'langforge';

  Directory? _logDir;
  File? _currentLogFile;
  StreamSubscription<LogRecord>? _subscription;

  /// Serialises appends and rotation. Records arrive faster than the file
  /// system responds, and two concurrent rotations would lose a file.
  Future<void> _writeChain = Future<void>.value();

  Directory? get logDirectory => _logDir;

  File? get currentLogFile => _currentLogFile;

  /// Prepares the log directory and starts listening to [Logger.root].
  ///
  /// [overrideDirectory] exists for tests; production resolves the directory
  /// from the platform.
  Future<void> init({Directory? overrideDirectory}) async {
    _logDir = overrideDirectory ?? await _resolveLogDirectory();
    if (!await _logDir!.exists()) {
      await _logDir!.create(recursive: true);
    }

    _currentLogFile = File(p.join(_logDir!.path, '$_baseName.log'));

    Logger.root.level = Level.INFO;
    await _subscription?.cancel();
    _subscription = Logger.root.onRecord.listen(_handleLogRecord);
  }

  Future<Directory> _resolveLogDirectory() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return Directory(p.join(appData, 'LangForge', 'logs'));
      }
    }
    final baseDir = await getApplicationSupportDirectory();
    return Directory(p.join(baseDir.path, 'LangForge', 'logs'));
  }

  void _handleLogRecord(LogRecord record) {
    unawaited(_enqueue(_formatRecord(record)));
  }

  String _formatRecord(LogRecord record) {
    final message = SensitiveFilter.scrub(record.message);
    final error = record.error != null
        ? SensitiveFilter.scrub(record.error.toString())
        : '';
    final timeStr = record.time.toIso8601String();
    return '[$timeStr] [${record.level.name}] [${record.loggerName}]: $message'
        '${error.isNotEmpty ? ' | Error: $error' : ''}\n';
  }

  Future<void> _enqueue(String line) {
    _writeChain = _writeChain.then((_) => _writeToFile(line));
    return _writeChain;
  }

  /// Waits for every queued record to reach disk. Tests and shutdown use this.
  Future<void> flush() => _writeChain;

  Future<void> _writeToFile(String line) async {
    final file = _currentLogFile;
    if (file == null) return;
    try {
      if (await file.exists() && await file.length() >= maxFileSizeBytes) {
        await _rotateLogs();
      }
      await _currentLogFile!.writeAsString(
        line,
        mode: FileMode.append,
        flush: true,
      );
    } on FileSystemException {
      // Logging the failure would recurse straight back into this method.
    }
  }

  Future<void> _rotateLogs() async {
    final dir = _logDir;
    if (dir == null) return;

    final oldest = File(p.join(dir.path, '$_baseName.${maxFiles - 1}.log'));
    if (await oldest.exists()) {
      await oldest.delete();
    }

    for (var i = maxFiles - 2; i >= 1; i--) {
      final source = File(p.join(dir.path, '$_baseName.$i.log'));
      if (await source.exists()) {
        await source.rename(p.join(dir.path, '$_baseName.${i + 1}.log'));
      }
    }

    final mainFile = File(p.join(dir.path, '$_baseName.log'));
    if (await mainFile.exists()) {
      await mainFile.rename(p.join(dir.path, '$_baseName.1.log'));
    }

    _currentLogFile = File(p.join(dir.path, '$_baseName.log'));
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await flush();
  }
}
