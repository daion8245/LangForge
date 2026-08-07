import 'package:drift/drift.dart';

class Conflicts extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceName => text()();
  TextColumn get key => text()();
  TextColumn get participantsJson =>
      text()(); // [{entryId, namespaceId, inputFileId, addOrder, sourceText}]

  /// What the conflict priority setting highlights. A suggestion only — it is
  /// never promoted to [resolvedEntryId] without the user confirming (AC-8.5).
  TextColumn get suggestedEntryId => text().nullable()();

  TextColumn get resolvedEntryId => text().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
