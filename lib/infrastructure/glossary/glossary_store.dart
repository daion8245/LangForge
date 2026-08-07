import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import '../../domain/glossary/glossary_policy.dart';
import '../../domain/glossary/glossary_term.dart';
import '../db/app_database.dart';
import '../db/glossary_database.dart';
import '../project/project_paths.dart';

/// Unified view of global + project glossary. TECHNICAL.md 7.5.
class GlossaryStore {
  GlossaryStore._(this._global, [this._projectDb]);

  final GlossaryDatabase _global;
  AppDatabase? _projectDb;

  static const _uuid = Uuid();

  static Future<GlossaryStore> open({AppDatabase? projectDb}) async {
    final file = await ProjectPaths.glossaryFile();
    return GlossaryStore._(GlossaryDatabase(NativeDatabase(file)), projectDb);
  }

  static GlossaryStore inMemory({AppDatabase? projectDb}) =>
      GlossaryStore._(GlossaryDatabase(NativeDatabase.memory()), projectDb);

  void attachProject(AppDatabase? projectDb) {
    _projectDb = projectDb;
  }

  Future<void> close() => _global.close();

  Future<List<GlossaryTerm>> listGlobal({
    String? sourceLang,
    String? targetLang,
    String? search,
  }) async {
    final rows = await _global.select(_global.globalGlossaryTerms).get();
    return _filterMap(rows.map(_fromGlobal), sourceLang, targetLang, search);
  }

  Future<List<GlossaryTerm>> listProject({
    String? sourceLang,
    String? targetLang,
    String? search,
  }) async {
    final db = _projectDb;
    if (db == null) return const [];
    final rows = await db.select(db.glossaryTerms).get();
    return _filterMap(rows.map(_fromProject), sourceLang, targetLang, search);
  }

  /// Project wins on identity collision.
  Future<List<GlossaryTerm>> mergedTerms() async {
    final global = await listGlobal();
    final project = await listProject();
    return GlossaryPolicy.mergeProjectOverGlobal(
      global: global,
      project: project,
    );
  }

  Future<GlossaryTerm> upsertGlobal(GlossaryTerm term) async {
    final id = term.id.isEmpty ? _uuid.v4() : term.id;
    final saved = term.id.isEmpty
        ? GlossaryTerm(
            id: id,
            sourceTerm: term.sourceTerm,
            targetTerm: term.targetTerm,
            sourceLang: term.sourceLang,
            targetLang: term.targetLang,
            namespace: term.namespace,
            caseSensitive: term.caseSensitive,
            note: term.note,
          )
        : term;
    await _global
        .into(_global.globalGlossaryTerms)
        .insertOnConflictUpdate(_toGlobalCompanion(saved));
    return saved;
  }

  Future<GlossaryTerm> upsertProject(GlossaryTerm term) async {
    final db = _projectDb;
    if (db == null) {
      throw StateError('No project database attached');
    }
    final id = term.id.isEmpty ? _uuid.v4() : term.id;
    final saved = term.id.isEmpty
        ? GlossaryTerm(
            id: id,
            sourceTerm: term.sourceTerm,
            targetTerm: term.targetTerm,
            sourceLang: term.sourceLang,
            targetLang: term.targetLang,
            namespace: term.namespace,
            caseSensitive: term.caseSensitive,
            note: term.note,
          )
        : term;
    await db
        .into(db.glossaryTerms)
        .insertOnConflictUpdate(_toProjectCompanion(saved));
    return saved;
  }

  Future<void> deleteGlobal(String id) async {
    await (_global.delete(
      _global.globalGlossaryTerms,
    )..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteProject(String id) async {
    final db = _projectDb;
    if (db == null) return;
    await (db.delete(db.glossaryTerms)..where((t) => t.id.equals(id))).go();
  }

  List<GlossaryTerm> _filterMap(
    Iterable<GlossaryTerm> terms,
    String? sourceLang,
    String? targetLang,
    String? search,
  ) {
    final q = search?.trim().toLowerCase();
    return [
      for (final term in terms)
        if ((sourceLang == null || term.sourceLang == sourceLang) &&
            (targetLang == null || term.targetLang == targetLang) &&
            (q == null ||
                q.isEmpty ||
                term.sourceTerm.toLowerCase().contains(q) ||
                term.targetTerm.toLowerCase().contains(q)))
          term,
    ];
  }

  GlossaryTerm _fromGlobal(GlobalGlossaryTermRow row) => GlossaryTerm(
    id: row.id,
    sourceTerm: row.sourceTerm,
    targetTerm: row.targetTerm,
    sourceLang: row.sourceLang,
    targetLang: row.targetLang,
    namespace: row.namespace,
    caseSensitive: row.caseSensitive,
    note: row.note,
  );

  GlossaryTerm _fromProject(ProjectGlossaryTermRow row) => GlossaryTerm(
    id: row.id,
    sourceTerm: row.sourceTerm,
    targetTerm: row.targetTerm,
    sourceLang: row.sourceLang,
    targetLang: row.targetLang,
    namespace: row.namespace,
    caseSensitive: row.caseSensitive,
    note: row.note,
  );

  GlobalGlossaryTermsCompanion _toGlobalCompanion(GlossaryTerm term) {
    return GlobalGlossaryTermsCompanion.insert(
      id: term.id,
      sourceTerm: term.sourceTerm,
      targetTerm: term.targetTerm,
      sourceLang: term.sourceLang,
      targetLang: term.targetLang,
      namespace: Value(term.namespace),
      caseSensitive: Value(term.caseSensitive),
      note: Value(term.note),
      updatedAt: DateTime.now(),
    );
  }

  GlossaryTermsCompanion _toProjectCompanion(GlossaryTerm term) {
    return GlossaryTermsCompanion.insert(
      id: term.id,
      sourceTerm: term.sourceTerm,
      targetTerm: term.targetTerm,
      sourceLang: term.sourceLang,
      targetLang: term.targetLang,
      namespace: Value(term.namespace),
      caseSensitive: Value(term.caseSensitive),
      note: Value(term.note),
      updatedAt: DateTime.now(),
    );
  }
}
