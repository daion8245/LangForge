import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/domain/provider/translation_provider.dart'
    show CancellationToken;
import 'package:langforge/infrastructure/isolate/messages.dart';
import 'package:langforge/infrastructure/isolate/worker_pool.dart';
import 'package:path/path.dart' as p;

/// Real JARs, so the pool is exercised against the same work the app does.
List<FileScanRequest> fixtureRequests(int copies) {
  final dir = Directory(p.join('test_fixtures', 'Example Mode'));
  final jars = dir
      .listSync()
      .whereType<File>()
      .where((f) => p.extension(f.path) == '.jar')
      .toList();

  return [
    for (var i = 0; i < copies; i++)
      for (final jar in jars) FileScanRequest(filePath: jar.path, kind: 'jar'),
  ];
}

void main() {
  group('WorkerPool', () {
    test('Pool size is bounded and at least one', () {
      expect(WorkerPool.poolSize, greaterThanOrEqualTo(1));
      expect(WorkerPool.poolSize, lessThanOrEqualTo(4));
    });

    test('An empty request list does no work', () async {
      final results = await WorkerPool.scanFiles(const []);
      expect(results, isEmpty);
    });

    test('Every request produces a response, in order', () async {
      final requests = fixtureRequests(1);
      expect(requests, isNotEmpty);

      final results = await WorkerPool.scanFiles(requests);

      expect(results.length, equals(requests.length));
      for (var i = 0; i < requests.length; i++) {
        expect(results[i].filePath, equals(requests[i].filePath));
      }
    });

    test('Concurrency does not corrupt results', () async {
      final requests = fixtureRequests(3);

      final serial = await WorkerPool.scanFiles(requests, concurrency: 1);
      final parallel = await WorkerPool.scanFiles(requests, concurrency: 4);

      expect(parallel.length, equals(serial.length));
      for (var i = 0; i < serial.length; i++) {
        expect(parallel[i].filePath, equals(serial[i].filePath));
        expect(parallel[i].sha256, equals(serial[i].sha256));
        expect(
          parallel[i].namespaces.length,
          equals(serial[i].namespaces.length),
        );
      }
    });

    test('A cancelled scan stops early', () async {
      final requests = fixtureRequests(8);
      final token = CancellationToken()..cancel();

      final results = await WorkerPool.scanFiles(requests, cancelToken: token);

      expect(results.length, lessThan(requests.length));
    });

    test('Progress messages are Korean and report totals', () async {
      final requests = fixtureRequests(1);
      final messages = <String>[];

      await WorkerPool.scanFiles(
        requests,
        onProgress: (current, total, message) {
          expect(total, equals(requests.length));
          messages.add(message);
        },
      );

      expect(messages, isNotEmpty);
      expect(messages.first, contains('탐색'));
      expect(messages.last, contains('완료'));
      // No stray English left over from the placeholder implementation.
      expect(
        messages.any((m) => m.contains('Scanning') || m.contains('Completed')),
        isFalse,
      );
    });
  });

  group('Streaming SHA-256', () {
    test('Matches across repeated scans of the same file', () async {
      final requests = fixtureRequests(1);
      final first = await WorkerPool.scanFiles(requests);
      final second = await WorkerPool.scanFiles(requests);

      for (var i = 0; i < first.length; i++) {
        expect(first[i].sha256, equals(second[i].sha256));
        expect(first[i].sha256.length, equals(64));
      }
    });

    test('Different files hash differently', () async {
      final results = await WorkerPool.scanFiles(fixtureRequests(1));
      final hashes = results.map((r) => r.sha256).toSet();
      expect(hashes.length, equals(results.length));
    });
  });
}
