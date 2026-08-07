import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/app.dart';
import 'package:langforge/application/db_provider.dart';
import 'package:langforge/infrastructure/db/app_database.dart';

void main() {
  testWidgets('LangForgeApp loads empty home screen', (
    WidgetTester tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const LangForgeApp(),
      ),
    );
    await tester.pump();

    expect(find.text('마인크래프트 모드 JAR 또는 리소스팩 추가'), findsOneWidget);

    await db.close();
    await tester.pumpWidget(const SizedBox());
  });
}
