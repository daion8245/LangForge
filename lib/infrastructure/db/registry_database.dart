import 'package:drift/drift.dart';

part 'registry_database.g.dart';

class RecentProjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get path => text()();
  DateTimeColumn get lastOpenedAt => dateTime()();
  IntColumn get totalKeys => integer().withDefault(const Constant(0))();
  IntColumn get doneKeys => integer().withDefault(const Constant(0))();
  BoolColumn get hasMissingFiles =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [RecentProjects])
class RegistryDatabase extends _$RegistryDatabase {
  RegistryDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<List<RecentProject>> getRecentProjects() async {
    return (select(recentProjects)
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.lastOpenedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(10))
        .get();
  }

  Future<void> addOrUpdateRecentProject(
    RecentProjectsCompanion companion,
  ) async {
    await into(recentProjects).insertOnConflictUpdate(companion);
  }

  Future<void> removeRecentProject(String id) async {
    await (delete(recentProjects)..where((t) => t.id.equals(id))).go();
  }
}
