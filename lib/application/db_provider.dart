import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/db/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(NativeDatabase.memory());
  ref.onDispose(() {
    db.close();
  });
  return db;
});
