import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/entry_status.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/db/daos/entry_dao.dart';
import '../conflict/conflict_providers.dart';
import '../db_provider.dart';
import '../project/project_language_pair.dart';

/// Project rows the mobile tabs share.
///
/// The desktop shell reads these through one `StreamBuilder` tree because it
/// draws all three panels at once. The phone draws one tab at a time, so the
/// same streams are lifted into providers instead — otherwise four tabs would
/// each open their own watch on the same three tables.
final mobileInputFilesProvider = StreamProvider<List<InputFile>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.inputFiles).watch();
});

final mobileNamespacesProvider = StreamProvider<List<Namespace>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.namespaces).watch();
});

final mobileLanguageFilesProvider = StreamProvider<List<LanguageFile>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.languageFiles).watch();
});

/// The failed entries the 문제 tab lists.
///
/// Capped rather than unbounded: a project can fail thousands of keys and the
/// tab is a work list, not a report. The count beside it comes from
/// [mobileProjectCountsProvider], which is computed in SQL, so a truncated list
/// never understates the real number.
const int mobileIssueListLimit = 100;

final mobileFailedEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.entryDao.watchPage(
    EntryQuery(
      statuses: [EntryStatus.invalid.wireName],
      limit: mobileIssueListLimit,
    ),
  );
});

/// One entry, watched by id — what the 편집 sheet is open on.
///
/// Watched rather than read once so a translation run landing on the same key
/// updates the sheet instead of leaving a stale status chip up.
final entryByIdProvider = StreamProvider.family<Entry?, String>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(
    db.entries,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();
});

/// Source and target codes for the project.
///
/// Every mobile surface that prints `en_us → ko_kr` reads this rather than
/// spelling either code out; the pair lives in `project_meta` and the user can
/// change it from the settings sheet.
final mobileLanguagePairProvider = FutureProvider<ProjectLanguagePair>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);
  return ProjectLanguagePair.fromDb(db);
});

/// Project-wide status counts — not the current namespace's.
///
/// The 문제 badge and the 출력 precheck both have to speak for the whole
/// project, so they cannot reuse `entryStatusCountsProvider`, which follows the
/// entry list's namespace filter.
final mobileProjectStatusCountsProvider = StreamProvider<Map<String, int>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db.entryDao.watchStatusCounts();
});

/// What the header, the 문제 badge and the 출력 verdict all read.
class MobileProjectCounts {
  const MobileProjectCounts({
    this.byStatus = const {},
    this.jsonErrorNamespaces = 0,
    this.noSourceNamespaces = 0,
    this.unresolvedConflicts = 0,
    this.selectedNamespaces = 0,
  });

  /// `EntryStatus.wireName -> count`, across the whole project.
  final Map<String, int> byStatus;

  final int jsonErrorNamespaces;
  final int noSourceNamespaces;
  final int unresolvedConflicts;

  /// Namespaces an export would actually write.
  final int selectedNamespaces;

  int of(EntryStatus status) => byStatus[status.wireName] ?? 0;

  int get total => byStatus.values.fold(0, (a, b) => a + b);

  /// Running counts as pending: the run is not done with it yet.
  int get pending => of(EntryStatus.wait) + of(EntryStatus.running);

  int get reused => of(EntryStatus.kept) + of(EntryStatus.cache);

  /// 원문 유지 + 확인 필요 — the two the user is asked to look at before export.
  int get needsReview => of(EntryStatus.fallback) + of(EntryStatus.confirm);

  int get failed => of(EntryStatus.invalid);

  /// Everything the 문제 tab lists, which is what the tab badge counts.
  int get issueCount =>
      failed + jsonErrorNamespaces + noSourceNamespaces + unresolvedConflicts;

  double? get percent => total == 0 ? null : (total - pending) / total;

  int get percentInt => ((percent ?? 0) * 100).round();
}

final mobileProjectCountsProvider = Provider<MobileProjectCounts>((ref) {
  final counts =
      ref.watch(mobileProjectStatusCountsProvider).asData?.value ??
      const <String, int>{};
  final namespaces =
      ref.watch(mobileNamespacesProvider).asData?.value ?? const <Namespace>[];
  final unresolved =
      ref.watch(unresolvedConflictCountProvider).asData?.value ?? 0;

  // A namespace the user turned off is not a problem the user has to solve —
  // only the ones still in scope count (AC-3.3 · AC-4.4).
  final inScope = namespaces.where((ns) => !ns.excluded && ns.selected);

  return MobileProjectCounts(
    byStatus: counts,
    jsonErrorNamespaces: inScope
        .where((ns) => ns.state == NamespaceState.jsonError.wireName)
        .length,
    noSourceNamespaces: inScope
        .where((ns) => ns.state == NamespaceState.noSource.wireName)
        .length,
    unresolvedConflicts: unresolved,
    selectedNamespaces: inScope
        .where(
          (ns) =>
              ns.state != NamespaceState.jsonError.wireName &&
              ns.state != NamespaceState.noSource.wireName,
        )
        .length,
  );
});
