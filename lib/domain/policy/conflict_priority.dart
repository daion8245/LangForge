/// How a namespace-key conflict picks its *suggested* winner (TECHNICAL.md 3.4).
///
/// Stored in `project_meta.conflict_priority` as [wireName], never as an
/// ordinal — reordering this enum must not corrupt existing projects.
///
/// Every value other than [manual] **preselects only**. The suggestion decides
/// which candidate is already highlighted when the conflict modal opens; it
/// never sets `conflicts.resolved`. Automatic overwriting stays forbidden
/// (AC-8.5), and unresolved conflicts keep blocking export (AC-8.6).
enum ConflictPriority {
  /// 항상 수동 선택. Nothing is preselected.
  manual('manual', '항상 수동 선택'),

  /// 먼저 추가된 JAR 의 원문.
  preferFirstAdded('preferFirstAdded', '먼저 추가된 파일 우선'),

  /// 나중에 추가된 JAR 의 원문.
  preferLastAdded('preferLastAdded', '나중에 추가된 파일 우선'),

  /// 원문이 더 긴 쪽.
  preferLongerSource('preferLongerSource', '원문이 긴 쪽 우선'),

  /// 원문이 더 짧은 쪽.
  preferShorterSource('preferShorterSource', '원문이 짧은 쪽 우선');

  const ConflictPriority(this.wireName, this.label);

  /// The exact string persisted in `project_meta.conflict_priority`.
  final String wireName;

  /// Korean label for the 충돌 처리 탭.
  final String label;

  /// Unknown values fall back to [manual]. A project written by a newer app
  /// must degrade to "ask the user", never to a silent automatic pick.
  static ConflictPriority fromWire(String? value) {
    for (final priority in ConflictPriority.values) {
      if (priority.wireName == value) return priority;
    }
    return ConflictPriority.manual;
  }
}
