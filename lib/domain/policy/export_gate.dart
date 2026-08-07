import '../model/entry_status.dart';
import '../model/translation_entry.dart';

/// See TECHNICAL.md 7.4. The first five reasons cannot be overridden by the
/// user; only the last two follow a policy choice.
enum BlockReason {
  jsonError,
  unresolvedConflict,
  corruptTargetFile,
  translationRunning,
  noNamespaceSelected,
  validationFailed,
  pendingEntries,
}

class ExportSummary {
  const ExportSummary({
    required this.totalKeys,
    required this.translatedKeys,
    required this.keptKeys,
    required this.pendingKeys,
    required this.failedKeys,
  });

  final int totalKeys;
  final int translatedKeys;
  final int keptKeys;
  final int pendingKeys;
  final int failedKeys;
}

sealed class ExportVerdict {}

final class Allowed extends ExportVerdict {
  Allowed(this.summary);

  final ExportSummary summary;
}

final class Blocked extends ExportVerdict {
  Blocked(this.reasons);

  final List<BlockReason> reasons;
}

/// The two user-selectable policies from TECHNICAL.md 7.4.
class ExportPolicyOptions {
  const ExportPolicyOptions({
    this.allowPendingEntries = true,
    this.allowValidationFailed = false,
  });

  /// Default: export untranslated entries with their source text.
  final bool allowPendingEntries;

  /// Default: refuse to export while validation failures exist.
  final bool allowValidationFailed;
}

abstract final class ExportGate {
  /// The namespaces an export writes files for.
  ///
  /// Broken and source-less namespaces are isolated, not exported — the rest of
  /// the project still ships (AC-3.3 · AC-4.4). Kept here so the gate's
  /// aggregate counts and the exporter's file list cannot drift apart.
  static List<NamespaceUnit> writableNamespaces(
    List<NamespaceUnit> namespaces,
  ) {
    return namespaces
        .where(
          (ns) =>
              !ns.excluded &&
              ns.selected &&
              ns.state != NamespaceState.jsonError &&
              ns.state != NamespaceState.noSource,
        )
        .toList();
  }

  /// Same rules as [evaluate], but fed pre-aggregated counts.
  ///
  /// [evaluate] needs every entry in memory purely to count statuses, which is
  /// exactly what a phone cannot afford for a 48,000-key project (MOBILE.md
  /// 1.2). The counts come out of SQL instead, and both paths run the same
  /// reason list below so the two can never disagree about what blocks an
  /// export.
  static ExportVerdict evaluateAggregate({
    required int activeNamespaceCount,
    required int jsonErrorNamespaceCount,
    required ExportSummary summary,
    required bool isTranslating,
    bool hasUnresolvedConflict = false,
    bool hasCorruptTargetFile = false,
    ExportPolicyOptions options = const ExportPolicyOptions(),
  }) {
    final reasons = <BlockReason>[];

    if (isTranslating) reasons.add(BlockReason.translationRunning);
    if (activeNamespaceCount == 0) {
      reasons.add(BlockReason.noNamespaceSelected);
    }
    if (jsonErrorNamespaceCount > 0) reasons.add(BlockReason.jsonError);
    if (hasUnresolvedConflict) reasons.add(BlockReason.unresolvedConflict);
    if (hasCorruptTargetFile) reasons.add(BlockReason.corruptTargetFile);
    if (!options.allowPendingEntries && summary.pendingKeys > 0) {
      reasons.add(BlockReason.pendingEntries);
    }
    if (!options.allowValidationFailed && summary.failedKeys > 0) {
      reasons.add(BlockReason.validationFailed);
    }

    return reasons.isEmpty ? Allowed(summary) : Blocked(reasons);
  }

  static ExportVerdict evaluate({
    required List<NamespaceUnit> namespaces,
    required List<TranslationEntry> entries,
    required bool isTranslating,
    bool hasUnresolvedConflict = false,
    bool hasCorruptTargetFile = false,
    ExportPolicyOptions options = const ExportPolicyOptions(),
  }) {
    final reasons = <BlockReason>[];

    if (isTranslating) {
      reasons.add(BlockReason.translationRunning);
    }

    final activeNamespaces = namespaces
        .where((ns) => !ns.excluded && ns.selected)
        .toList();
    if (activeNamespaces.isEmpty) {
      reasons.add(BlockReason.noNamespaceSelected);
    }

    if (activeNamespaces.any((ns) => ns.state == NamespaceState.jsonError)) {
      reasons.add(BlockReason.jsonError);
    }

    if (hasUnresolvedConflict) {
      reasons.add(BlockReason.unresolvedConflict);
    }

    if (hasCorruptTargetFile) {
      reasons.add(BlockReason.corruptTargetFile);
    }

    final activeNsIds = activeNamespaces.map((ns) => ns.id).toSet();
    final activeEntries = entries
        .where((e) => activeNsIds.contains(e.namespaceId))
        .toList();

    var translatedKeys = 0;
    var keptKeys = 0;
    var pendingKeys = 0;
    var failedKeys = 0;

    for (final entry in activeEntries) {
      switch (entry.status) {
        case EntryStatus.done:
          translatedKeys++;
        case EntryStatus.kept:
        case EntryStatus.cache:
          keptKeys++;
        case EntryStatus.wait:
        case EntryStatus.running:
          pendingKeys++;
        case EntryStatus.invalid:
          failedKeys++;
        case EntryStatus.fallback:
        case EntryStatus.confirm:
        case EntryStatus.empty:
          break;
      }
    }

    if (!options.allowPendingEntries && pendingKeys > 0) {
      reasons.add(BlockReason.pendingEntries);
    }

    if (!options.allowValidationFailed && failedKeys > 0) {
      reasons.add(BlockReason.validationFailed);
    }

    if (reasons.isNotEmpty) {
      return Blocked(reasons);
    }

    return Allowed(
      ExportSummary(
        totalKeys: activeEntries.length,
        translatedKeys: translatedKeys,
        keptKeys: keptKeys,
        pendingKeys: pendingKeys,
        failedKeys: failedKeys,
      ),
    );
  }
}
