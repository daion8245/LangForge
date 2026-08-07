/// The nine states a translation entry can be in. See TECHNICAL.md 3.4 and
/// EXPERIENCE.md 5.
///
/// Stored in the database as [wireName], never as an ordinal — reordering this
/// enum must not corrupt existing projects.
enum EntryStatus {
  /// 대기 — not translated yet.
  wait('wait'),

  /// 번역 중 — in flight.
  running('running'),

  /// 새 번역 — produced by a provider in this run.
  done('done'),

  /// 기존 번역 유지 — came from the input file's target language JSON.
  kept('kept'),

  /// 캐시 재사용. [1.0]
  cache('cache'),

  /// 검증 실패 — token mismatch, damaged placeholder, or a permanent API error.
  invalid('invalid'),

  /// 원문 유지 — deliberately not translated (excluded value, user action).
  fallback('fallback'),

  /// 확인 필요 — needs the user to look at it before export.
  confirm('confirm'),

  /// 빈 문자열 유지 — source text is empty, so there is nothing to translate.
  empty('empty');

  const EntryStatus(this.wireName);

  /// The exact string persisted in the `entries.status` column.
  final String wireName;

  static EntryStatus fromWire(String value) {
    for (final status in EntryStatus.values) {
      if (status.wireName == value) return status;
    }
    throw ArgumentError.value(value, 'value', 'Unknown EntryStatus');
  }
}

/// See TECHNICAL.md 3.4.
enum NamespaceState {
  ok('ok'),
  noSource('noSource'),
  jsonError('jsonError'),
  conflicted('conflicted'),
  excluded('excluded'),
  done('done');

  const NamespaceState(this.wireName);

  final String wireName;

  static NamespaceState fromWire(String value) {
    for (final state in NamespaceState.values) {
      if (state.wireName == value) return state;
    }
    throw ArgumentError.value(value, 'value', 'Unknown NamespaceState');
  }
}

/// See TECHNICAL.md 3.4.
enum ScanState {
  pending('pending'),
  ok('ok'),
  rejected('rejected'),
  missing('missing'),
  changed('changed');

  const ScanState(this.wireName);

  final String wireName;

  static ScanState fromWire(String value) {
    for (final state in ScanState.values) {
      if (state.wireName == value) return state;
    }
    throw ArgumentError.value(value, 'value', 'Unknown ScanState');
  }
}
