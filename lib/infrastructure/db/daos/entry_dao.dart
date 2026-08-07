import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/entries.dart';

part 'entry_dao.g.dart';

/// How many rows one page of the entry list holds.
///
/// A project can hold tens of thousands of entries; the list must never load
/// them all at once (AGENTS.md 5.6).
const int entryPageSize = 200;

class EntryQuery {
  const EntryQuery({
    this.namespaceId,
    this.status,
    this.statuses,
    this.searchText,
    this.offset = 0,
    this.limit = entryPageSize,
  });

  final String? namespaceId;

  /// `EntryStatus.wireName`, or null for every status.
  final String? status;

  /// Several statuses at once, for filters like `문제` that span more than one
  /// (AC-7.7). Takes precedence over [status] when both are set.
  final List<String>? statuses;

  /// The statuses this query accepts, or null when it accepts all of them.
  List<String>? get statusFilterValues {
    final many = statuses;
    if (many != null && many.isNotEmpty) return many;
    final one = status;
    return one == null ? null : [one];
  }

  /// Matched against key and source text with LIKE (TECHNICAL.md 3.3).
  final String? searchText;

  final int offset;
  final int limit;

  EntryQuery copyWith({
    String? namespaceId,
    String? status,
    List<String>? statuses,
    String? searchText,
    int? offset,
    int? limit,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return EntryQuery(
      namespaceId: namespaceId ?? this.namespaceId,
      status: clearStatus ? null : (status ?? this.status),
      statuses: clearStatus ? null : (statuses ?? this.statuses),
      searchText: clearSearch ? null : (searchText ?? this.searchText),
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }
}

@DriftAccessor(tables: [Entries])
class EntryDao extends DatabaseAccessor<AppDatabase> with _$EntryDaoMixin {
  EntryDao(super.db);

  SimpleSelectStatement<$EntriesTable, Entry> _filtered(EntryQuery query) {
    final select = this.select(entries);

    final namespaceId = query.namespaceId;
    if (namespaceId != null) {
      select.where((tbl) => tbl.namespaceId.equals(namespaceId));
    }

    final statusValues = query.statusFilterValues;
    if (statusValues != null) {
      select.where((tbl) => tbl.status.isIn(statusValues));
    }

    final search = query.searchText?.trim();
    if (search != null && search.isNotEmpty) {
      final pattern = '%${_escapeLike(search)}%';
      select.where(
        (tbl) =>
            _likeEscaped(tbl.key, pattern) |
            _likeEscaped(tbl.sourceText, pattern),
      );
    }

    return select;
  }

  /// One page of entries in original JSON key order.
  Stream<List<Entry>> watchPage(EntryQuery query) {
    final select = _filtered(query)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.keyOrder)])
      ..limit(query.limit, offset: query.offset);
    return select.watch();
  }

  Future<List<Entry>> getPage(EntryQuery query) {
    final select = _filtered(query)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.keyOrder)])
      ..limit(query.limit, offset: query.offset);
    return select.get();
  }

  /// Row count for the same filter, computed in SQL so the UI can show totals
  /// without holding the rows.
  Stream<int> watchCount(EntryQuery query) {
    final countExp = entries.id.count();
    final statement = selectOnly(entries)..addColumns([countExp]);

    final namespaceId = query.namespaceId;
    if (namespaceId != null) {
      statement.where(entries.namespaceId.equals(namespaceId));
    }
    final statusValues = query.statusFilterValues;
    if (statusValues != null) {
      statement.where(entries.status.isIn(statusValues));
    }
    final search = query.searchText?.trim();
    if (search != null && search.isNotEmpty) {
      final pattern = '%${_escapeLike(search)}%';
      statement.where(
        _likeEscaped(entries.key, pattern) |
            _likeEscaped(entries.sourceText, pattern),
      );
    }

    return statement.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  /// `status -> count` for the current namespace, for the filter bar.
  Stream<Map<String, int>> watchStatusCounts({String? namespaceId}) {
    final countExp = entries.id.count();
    final statement = selectOnly(entries)
      ..addColumns([entries.status, countExp])
      ..groupBy([entries.status]);

    if (namespaceId != null) {
      statement.where(entries.namespaceId.equals(namespaceId));
    }

    return statement.watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        final status = row.read(entries.status);
        if (status != null) counts[status] = row.read(countExp) ?? 0;
      }
      return counts;
    });
  }

  /// Drift's `like()` emits no ESCAPE clause, so the backslashes added by
  /// [_escapeLike] would be matched literally. Spell the comparison out.
  ///
  /// The pattern is embedded as a quoted SQL literal with its single quotes
  /// doubled, which is how SQLite escapes them — there is no way for the
  /// search box to break out of the string.
  static Expression<bool> _likeEscaped(
    GeneratedColumn<String> column,
    String pattern,
  ) {
    final literal = "'${pattern.replaceAll("'", "''")}'";
    return CustomExpression<bool>(
      '${column.name} LIKE $literal ESCAPE ${r"'\'"}',
    );
  }

  /// LIKE treats these as wildcards, so a user searching for `%` or `_` would
  /// otherwise match everything.
  static String _escapeLike(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }
}
