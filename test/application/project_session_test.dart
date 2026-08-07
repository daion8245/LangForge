import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/project/project_session.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/project/registry_service.dart';
import 'package:path/path.dart' as p;

ProviderContainer makeContainer() {
  final container = ProviderContainer(
    overrides: [
      // The real registry lives in %APPDATA%; a test must never write there.
      registryServiceProvider.overrideWith((ref) async {
        final service = RegistryService.inMemory();
        ref.onDispose(service.close);
        return service;
      }),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> seedOneEntry(AppDatabase db, {required String value}) async {
  final now = DateTime.now();
  await db
      .into(db.inputFiles)
      .insert(
        InputFilesCompanion.insert(
          id: 'f1',
          originalName: 'Quark-4.0.jar',
          absolutePath: '/tmp/Quark-4.0.jar',
          kind: 'jar',
          sizeBytes: 1,
          sha256: 'h',
          addedAt: now,
          scanState: 'ok',
        ),
      );
  await db
      .into(db.namespaces)
      .insert(
        NamespacesCompanion.insert(
          id: 'ns1',
          inputFileId: 'f1',
          name: 'quark',
          state: 'ok',
        ),
      );
  await db
      .into(db.entries)
      .insert(
        EntriesCompanion.insert(
          id: 'e1',
          namespaceId: 'ns1',
          key: 'item.wand',
          keyOrder: 0,
          sourceText: 'Wand',
          userTranslation: Value(value),
          userEdited: const Value(true),
          status: 'confirm',
          updatedAt: now,
        ),
      );
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('session_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows may still hold a handle; the OS reclaims it.
      }
    }
  });

  test('A fresh session starts closed, on the start screen', () {
    final container = makeContainer();
    final session = container.read(projectSessionProvider);

    expect(session.isOpen, isFalse);
    expect(session.hasFile, isFalse);
    expect(session.name, equals(ProjectSession.defaultName));
  });

  test('새 프로젝트 opens an unsaved project', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    final session = container.read(projectSessionProvider);

    expect(session.isOpen, isTrue);
    expect(session.hasFile, isFalse);
  });

  test(
    'Saving an unsaved project asks for a location first (AC-10.8)',
    () async {
      final container = makeContainer();
      final notifier = container.read(projectSessionProvider.notifier);

      await notifier.newProject();

      expect(await notifier.save(), equals(SaveOutcome.needsLocation));
    },
  );

  test('IT-5 — save, close, reopen restores the project (AC-10.3)', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    await seedOneEntry(container.read(projectSessionProvider).db, value: '완드');
    await notifier.rename('MyPack');

    final path = p.join(tempDir.path, 'MyPack.lfproj');
    expect(await notifier.saveAs(path), equals(SaveOutcome.saved));

    var session = container.read(projectSessionProvider);
    expect(session.hasFile, isTrue);
    expect(session.isDirty, isFalse);

    await notifier.closeProject();
    expect(container.read(projectSessionProvider).isOpen, isFalse);

    expect(await notifier.openProject(path), isTrue);
    session = container.read(projectSessionProvider);

    expect(session.isOpen, isTrue);
    expect(session.name, equals('MyPack'));

    final entry = await session.db.select(session.db.entries).getSingle();
    expect(entry.userTranslation, equals('완드'));
    expect(entry.status, equals('confirm'));
  });

  test('A reopened project appears in the recent list (AC-10.2)', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    final path = p.join(tempDir.path, 'Recent.lfproj');
    await notifier.saveAs(path);

    final registry = await container.read(registryServiceProvider.future);
    final recents = await registry.recentProjects();

    expect(recents.map((r) => r.path), contains(path));
  });

  test(
    'The project takes its name from the first input file (AC-10.9)',
    () async {
      final container = makeContainer();
      final notifier = container.read(projectSessionProvider.notifier);

      await notifier.newProject();
      notifier.suggestNameFromInput('Quark-4.0-1.20.1.jar');

      expect(
        container.read(projectSessionProvider).name,
        equals('Quark-4.0-1.20.1'),
      );

      // A name the user already chose is never overwritten by a later file.
      notifier.suggestNameFromInput('Botania-1.20.jar');
      expect(
        container.read(projectSessionProvider).name,
        equals('Quark-4.0-1.20.1'),
      );
    },
  );

  test(
    'Opening a file that is not a project reports instead of throwing',
    () async {
      final container = makeContainer();
      final notifier = container.read(projectSessionProvider.notifier);

      final bogus = p.join(tempDir.path, 'nope.lfproj');
      File(bogus).writeAsStringSync('not a database');

      expect(await notifier.openProject(bogus), isFalse);
      expect(container.read(projectSessionProvider).errorMessage, isNotNull);
      expect(container.read(projectSessionProvider).isOpen, isFalse);
    },
  );

  test('A missing input file is reported on open (AC-10.4)', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    await seedOneEntry(container.read(projectSessionProvider).db, value: '완드');

    final path = p.join(tempDir.path, 'Missing.lfproj');
    await notifier.saveAs(path);
    await notifier.closeProject();

    await notifier.openProject(path);
    final session = container.read(projectSessionProvider);

    expect(session.notices, isNotEmpty);
    expect(session.notices.first, contains('삭제된 입력 파일'));

    final namespace = await session.db
        .select(session.db.namespaces)
        .getSingle();
    expect(namespace.excluded, isTrue);
  });

  test('markDirty auto-saves after the debounce (AC-10.1)', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    await notifier.saveAs(p.join(tempDir.path, 'Auto.lfproj'));

    notifier.markDirty();
    expect(container.read(projectSessionProvider).isDirty, isTrue);

    await Future<void>.delayed(
      ProjectSessionController.autoSaveDebounce + const Duration(seconds: 1),
    );

    expect(container.read(projectSessionProvider).isDirty, isFalse);
    expect(container.read(projectSessionProvider).lastSavedAt, isNotNull);
  });

  test('An unsaved project does not auto-save behind the user', () async {
    final container = makeContainer();
    final notifier = container.read(projectSessionProvider.notifier);

    await notifier.newProject();
    notifier.markDirty();

    await Future<void>.delayed(
      ProjectSessionController.autoSaveDebounce +
          const Duration(milliseconds: 500),
    );

    // Still dirty, and still no file: the first save is the user's decision.
    expect(container.read(projectSessionProvider).isDirty, isTrue);
    expect(container.read(projectSessionProvider).hasFile, isFalse);
  });
}
