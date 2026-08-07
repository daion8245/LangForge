import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/app.dart';
import 'package:langforge/application/project/project_session.dart';
import 'package:langforge/infrastructure/project/registry_service.dart';

/// The real registry lives in `%APPDATA%`; a test must never touch it.
ProviderScope _app() {
  return ProviderScope(
    overrides: [
      registryServiceProvider.overrideWith((ref) async {
        final service = RegistryService.inMemory();
        ref.onDispose(service.close);
        return service;
      }),
    ],
    child: const LangForgeApp(),
  );
}

void main() {
  testWidgets('The app opens on the start screen (S0)', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.text('최근 프로젝트'), findsOneWidget);
    expect(find.text('+ 새 프로젝트'), findsOneWidget);
    expect(find.text('저장된 최근 프로젝트가 없습니다.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('새 프로젝트 moves on to the empty project screen (S1)', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump();

    await tester.tap(find.text('+ 새 프로젝트'));
    await tester.pumpAndSettle();

    expect(find.text('마인크래프트 모드 JAR 또는 리소스팩 추가'), findsOneWidget);

    // Tearing down closes the project database, which finishes on a timer.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
