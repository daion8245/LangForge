import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/app/theme/lf_colors.dart';
import 'package:langforge/app/theme/lf_radii.dart';
import 'package:langforge/app/theme/lf_sizes.dart';
import 'package:langforge/app/theme/lf_spacing.dart';
import 'package:langforge/app/theme/lf_typography.dart';
import 'package:langforge/application/cache/cache_providers.dart';
import 'package:langforge/application/db_provider.dart';
import 'package:langforge/domain/glossary/glossary_term.dart';
import 'package:langforge/infrastructure/db/app_database.dart';
import 'package:langforge/infrastructure/glossary/glossary_store.dart';
import 'package:langforge/infrastructure/project/project_service.dart';
import 'package:langforge/presentation/glossary/glossary_screen.dart';

import '../support/provider_test_setup.dart';

Widget glossaryApp({required GlossaryStore glossary, required AppDatabase db}) {
  return ProviderScope(
    overrides: [
      glossaryStoreProvider.overrideWith((ref) => glossary),
      appDatabaseProvider.overrideWith((ref) => db),
    ],
    child: MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: [
          LfColors.dark,
          LfSpacing.standard,
          LfRadii.standard,
          LfTypography.standard,
          LfSizes.standard,
        ],
      ),
      home: const GlossaryScreen(),
    ),
  );
}

void main() {
  setUpAll(loadProvidersForTest);

  late AppDatabase db;
  late GlossaryStore glossary;

  setUp(() {
    db = ProjectService.inMemory();
    glossary = GlossaryStore.inMemory(projectDb: db);
  });

  tearDown(() async {
    await glossary.close();
    await db.close();
  });

  testWidgets('S12 builds empty state and add control', (tester) async {
    await tester.pumpWidget(glossaryApp(glossary: glossary, db: db));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('용어집'), findsOneWidget);
    expect(find.text('등록된 용어가 없습니다'), findsOneWidget);
    expect(find.text('추가'), findsWidgets);
    expect(find.text('전역'), findsOneWidget);
    expect(find.text('프로젝트'), findsOneWidget);
  });

  testWidgets('S12 lists a global term', (tester) async {
    await glossary.upsertGlobal(
      const GlossaryTerm(
        id: 'g1',
        sourceTerm: 'Copper Ingot',
        targetTerm: '구리 주괴',
        sourceLang: 'en_us',
        targetLang: 'ko_kr',
      ),
    );

    await tester.pumpWidget(glossaryApp(glossary: glossary, db: db));
    await tester.pumpAndSettle();

    expect(find.text('Copper Ingot'), findsOneWidget);
    expect(find.textContaining('구리 주괴'), findsOneWidget);
  });

  testWidgets('S12 survives 2.0x text scale', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: glossaryApp(glossary: glossary, db: db),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('용어집'), findsOneWidget);
  });
}
