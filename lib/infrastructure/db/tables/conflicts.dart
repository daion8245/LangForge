import 'package:drift/drift.dart';

class Conflicts extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceName => text()();
  TextColumn get key => text()();
  TextColumn get participantsJson =>
      text()(); // [{inputFileId, sourceText, translation}]
  TextColumn get resolvedEntryId => text().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
