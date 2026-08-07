import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/cache/translation_cache_store.dart';
import '../../infrastructure/glossary/glossary_store.dart';

/// Opened in [bootstrap] and injected via `ProviderScope.overrides`.
/// `null` means cache is disabled (unit tests that do not care about it).
final translationCacheStoreProvider = Provider<TranslationCacheStore?>((ref) {
  return null;
});

/// Opened in [bootstrap]. Attach the open project with [GlossaryStore.attachProject].
final glossaryStoreProvider = Provider<GlossaryStore?>((ref) {
  return null;
});
