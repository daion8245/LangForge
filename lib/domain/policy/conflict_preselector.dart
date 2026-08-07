import '../validation/conflict_detector.dart';
import 'conflict_priority.dart';

/// Turns a [ConflictPriority] into a *suggested* participant.
///
/// This is the whole reach of the automatic priority setting. It answers "which
/// candidate should already be highlighted when the user opens the conflict
/// modal", nothing more — the pick is written to `conflicts.suggested_entry_id`
/// and `conflicts.resolved` stays false until the user confirms (AC-8.5).
abstract final class ConflictPreselector {
  /// The participant to highlight, or null when the user must choose unaided.
  ///
  /// Ties break toward the earliest [ConflictParticipant.addOrder], then the
  /// lowest entry id, so the same project always suggests the same side.
  static ConflictParticipant? suggest({
    required ConflictItem conflict,
    required ConflictPriority priority,
  }) {
    final participants = conflict.participants;
    if (participants.isEmpty) return null;
    if (priority == ConflictPriority.manual) return null;

    switch (priority) {
      case ConflictPriority.manual:
        return null;

      case ConflictPriority.preferFirstAdded:
        return participants.reduce((a, b) => _isEarlier(b, a) ? b : a);

      case ConflictPriority.preferLastAdded:
        return participants.reduce((a, b) => _isEarlier(a, b) ? b : a);

      case ConflictPriority.preferLongerSource:
        return participants.reduce((a, b) {
          if (b.sourceText.length > a.sourceText.length) return b;
          if (b.sourceText.length < a.sourceText.length) return a;
          return _isEarlier(b, a) ? b : a;
        });

      case ConflictPriority.preferShorterSource:
        return participants.reduce((a, b) {
          if (b.sourceText.length < a.sourceText.length) return b;
          if (b.sourceText.length > a.sourceText.length) return a;
          return _isEarlier(b, a) ? b : a;
        });
    }
  }

  /// Add order first, entry id as the deterministic tiebreak.
  static bool _isEarlier(ConflictParticipant a, ConflictParticipant b) {
    if (a.addOrder != b.addOrder) return a.addOrder < b.addOrder;
    return a.entryId.compareTo(b.entryId) < 0;
  }
}
