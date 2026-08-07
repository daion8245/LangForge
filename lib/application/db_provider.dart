import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/db/app_database.dart';
import 'project/project_session.dart';

/// The database of the project that is currently open.
///
/// Ownership lives in [projectSessionProvider]: opening or saving a project
/// swaps the instance, and everything watching this provider re-subscribes to
/// the new one. Nothing else may close it.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(projectSessionProvider.select((session) => session.db));
});
