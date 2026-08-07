import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../application/cache/cache_providers.dart';
import '../infrastructure/cache/translation_cache_store.dart';
import '../infrastructure/glossary/glossary_store.dart';
import '../infrastructure/language/language_profile_catalog.dart';
import '../infrastructure/logging/file_logger.dart';
import '../infrastructure/logging/log_buffer.dart';
import '../infrastructure/platform/app_platform.dart';
import '../infrastructure/provider/provider_catalog.dart';
import '../infrastructure/provider/provider_registry.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opening or saving a project swaps the database instance, so more than one
  // AppDatabase legitimately exists over a session. The previous one is always
  // closed first, which is the race the warning is about.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Initialize Logger & SensitiveFilter
  await FileLogger.instance.init();
  LogBuffer.instance.start();

  // Endpoints and model lists come from assets/data/providers.json (Phase 8).
  await ProviderCatalog.load();
  ProviderRegistry.initialize();

  // The six target languages come from assets/data/language_profiles.json
  // (Phase 11).
  await LanguageProfileCatalog.load();

  final cacheStore = await TranslationCacheStore.open();
  final glossaryStore = await GlossaryStore.open();

  // Window management is desktop-only. window_manager ships no Android
  // implementation, so calling it there fails the whole boot rather than
  // degrading (Phase 13).
  if (AppPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'LangForge',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ProviderScope(
      overrides: [
        translationCacheStoreProvider.overrideWith((ref) => cacheStore),
        glossaryStoreProvider.overrideWith((ref) => glossaryStore),
      ],
      child: builder(),
    ),
  );
}
