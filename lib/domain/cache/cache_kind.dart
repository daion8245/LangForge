/// Classification of a cached translation. See TECHNICAL.md 7.5.
enum CacheKind {
  /// Provider output that passed validation (`done` → write).
  auto('auto'),

  /// User approved a `confirm` entry.
  reviewed('reviewed'),

  /// Value the user typed themselves.
  userEdited('userEdited');

  const CacheKind(this.wireName);

  final String wireName;

  /// Lookup preference when several kinds share the same 8-element key.
  static const List<CacheKind> lookupOrder = [
    CacheKind.userEdited,
    CacheKind.reviewed,
    CacheKind.auto,
  ];

  /// Kinds that feed MergePolicy step 4 (never [auto]).
  static const List<CacheKind> mergeStep4 = [
    CacheKind.userEdited,
    CacheKind.reviewed,
  ];

  static CacheKind fromWire(String value) {
    for (final kind in CacheKind.values) {
      if (kind.wireName == value) return kind;
    }
    throw ArgumentError.value(value, 'value', 'Unknown CacheKind');
  }
}
