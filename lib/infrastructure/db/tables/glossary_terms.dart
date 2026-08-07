import 'package:drift/drift.dart';

/// Project glossary rows inside `.lfproj`. TECHNICAL.md 3.2 · 7.5.
@DataClassName('ProjectGlossaryTermRow')
class GlossaryTerms extends Table {
  TextColumn get id => text()();
  TextColumn get sourceTerm => text()();
  TextColumn get targetTerm => text()();
  TextColumn get sourceLang => text()();
  TextColumn get targetLang => text()();
  TextColumn get namespace => text().nullable()();
  BoolColumn get caseSensitive =>
      boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
