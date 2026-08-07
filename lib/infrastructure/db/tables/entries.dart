import 'package:drift/drift.dart';
import 'namespaces.dart';

class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get namespaceId =>
      text().references(Namespaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get keyCategory =>
      text().nullable()(); // block | item | gui | tooltip | ...
  IntColumn get keyOrder => integer()(); // 원본 JSON 의 key 순서 보존

  TextColumn get sourceText => text()();
  TextColumn get existingTranslation => text().nullable()();
  TextColumn get newTranslation => text().nullable()();
  TextColumn get userTranslation => text().nullable()();

  TextColumn get status => text()(); // EntryStatus string
  TextColumn get providerId => text().nullable()();
  TextColumn get modelId => text().nullable()();
  BoolColumn get userEdited => boolean().withDefault(const Constant(false))();
  TextColumn get validationJson => text().nullable()();
  TextColumn get warningsJson => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
