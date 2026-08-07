import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/entry_status.dart';
import '../../infrastructure/db/app_database.dart';
import '../../infrastructure/db/daos/entry_dao.dart';
import '../db_provider.dart';

/// The filter key the 문제 tab uses. It is not an [EntryStatus] — it stands for
/// the group of statuses that need the user's attention (AC-7.7).
const String problemStatusFilter = 'problem';

/// 검증 실패 · 원문 유지 · 확인 필요. `빈 문자열 유지` is a normal outcome and is
/// deliberately not in this list.
const List<String> problemStatuses = <String>['invalid', 'fallback', 'confirm'];

/// Which slice of the entry table the list is currently showing.
class EntriesViewState {
  const EntriesViewState({
    this.namespaceId,
    this.statusFilter,
    this.searchText,
    this.loadedPages = 1,
  });

  final String? namespaceId;

  /// `EntryStatus.wireName`, or null for 전체.
  final String? statusFilter;

  final String? searchText;

  /// Grows as the user scrolls. Rows held in memory stay bounded by
  /// [entryPageSize] × this.
  final int loadedPages;

  int get limit => entryPageSize * loadedPages;

  EntryQuery get query => EntryQuery(
    namespaceId: namespaceId,
    status: statusFilter == problemStatusFilter ? null : statusFilter,
    statuses: statusFilter == problemStatusFilter ? problemStatuses : null,
    searchText: searchText,
    limit: limit,
  );

  EntriesViewState copyWith({
    String? namespaceId,
    String? statusFilter,
    String? searchText,
    int? loadedPages,
    bool clearNamespace = false,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return EntriesViewState(
      namespaceId: clearNamespace ? null : (namespaceId ?? this.namespaceId),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      searchText: clearSearch ? null : (searchText ?? this.searchText),
      loadedPages: loadedPages ?? this.loadedPages,
    );
  }
}

/// Owns the entry list's filter and paging state.
///
/// Every change that narrows the result set resets paging — otherwise a user
/// who scrolled deep into 전체 would keep 10,000 rows loaded after filtering
/// down to a handful.
class EntriesViewController extends Notifier<EntriesViewState> {
  @override
  EntriesViewState build() => const EntriesViewState();

  void selectNamespace(String? namespaceId) {
    state = EntriesViewState(
      namespaceId: namespaceId,
      statusFilter: state.statusFilter,
      searchText: state.searchText,
    );
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatus: status == null,
      loadedPages: 1,
    );
  }

  void setSearchText(String? text) {
    final trimmed = text?.trim();
    final isEmpty = trimmed == null || trimmed.isEmpty;
    state = state.copyWith(
      searchText: trimmed,
      clearSearch: isEmpty,
      loadedPages: 1,
    );
  }

  void loadMore() {
    state = state.copyWith(loadedPages: state.loadedPages + 1);
  }
}

final entriesViewControllerProvider =
    NotifierProvider<EntriesViewController, EntriesViewState>(
      EntriesViewController.new,
    );

/// The rows currently on screen — never the whole table.
final entriesPageProvider = StreamProvider.autoDispose<List<Entry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final view = ref.watch(entriesViewControllerProvider);
  return db.entryDao.watchPage(view.query);
});

/// Total rows matching the current filter, counted in SQL.
final entriesTotalCountProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final view = ref.watch(entriesViewControllerProvider);
  return db.entryDao.watchCount(view.query);
});

/// Per-status counts for the filter bar, counted in SQL.
final entryStatusCountsProvider = StreamProvider.autoDispose<Map<String, int>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final view = ref.watch(entriesViewControllerProvider);
  return db.entryDao.watchStatusCounts(namespaceId: view.namespaceId);
});
