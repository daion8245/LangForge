// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_dao.dart';

// ignore_for_file: type=lint
mixin _$EntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $InputFilesTable get inputFiles => attachedDatabase.inputFiles;
  $NamespacesTable get namespaces => attachedDatabase.namespaces;
  $EntriesTable get entries => attachedDatabase.entries;
  EntryDaoManager get managers => EntryDaoManager(this);
}

class EntryDaoManager {
  final _$EntryDaoMixin _db;
  EntryDaoManager(this._db);
  $$InputFilesTableTableManager get inputFiles =>
      $$InputFilesTableTableManager(_db.attachedDatabase, _db.inputFiles);
  $$NamespacesTableTableManager get namespaces =>
      $$NamespacesTableTableManager(_db.attachedDatabase, _db.namespaces);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
}
