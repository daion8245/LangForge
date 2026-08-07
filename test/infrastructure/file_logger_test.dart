import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/logging/file_logger.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late FileLogger logger;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('langforge_log_test');
    logger = FileLogger.instance;
    await logger.init(overrideDirectory: tempDir);
  });

  tearDown(() async {
    await logger.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  File logFile(String name) => File(p.join(tempDir.path, name));

  group('FileLogger', () {
    test('Creates the log file and appends records', () async {
      Logger('scan').info('scan finished');
      await logger.flush();

      final file = logFile('langforge.log');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains('scan finished'));
      expect(content, contains('[INFO]'));
      expect(content, contains('[scan]'));
    });

    test('Scrubs credentials before they reach disk', () async {
      Logger('net').warning('retry with x-goog-api-key: super_secret_value');
      await logger.flush();

      final content = logFile('langforge.log').readAsStringSync();
      expect(content, isNot(contains('super_secret_value')));
      expect(content, contains('[REDACTED]'));
    });

    test('Rotates when the file reaches the size cap', () async {
      final file = logFile('langforge.log');
      await file.writeAsString('x' * FileLogger.maxFileSizeBytes);

      Logger('scan').info('after rotation');
      await logger.flush();

      expect(logFile('langforge.1.log').existsSync(), isTrue);
      expect(
        logFile('langforge.1.log').lengthSync(),
        equals(FileLogger.maxFileSizeBytes),
      );

      final current = file.readAsStringSync();
      expect(current, contains('after rotation'));
      expect(current.length, lessThan(FileLogger.maxFileSizeBytes));
    });

    test('Keeps at most maxFiles files and drops the oldest', () async {
      for (var round = 0; round < FileLogger.maxFiles + 2; round++) {
        await logFile(
          'langforge.log',
        ).writeAsString('$round${'x' * FileLogger.maxFileSizeBytes}');
        Logger('scan').info('round $round');
        await logger.flush();
      }

      final names = tempDir
          .listSync()
          .map((e) => p.basename(e.path))
          .where((name) => name.startsWith('langforge'))
          .toList();

      expect(names.length, equals(FileLogger.maxFiles));
      expect(names, contains('langforge.log'));
      expect(names, isNot(contains('langforge.${FileLogger.maxFiles}.log')));
    });
  });
}
