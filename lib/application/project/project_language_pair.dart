import '../../infrastructure/db/app_database.dart';

/// Source/target codes from [ProjectMeta], never hardcoded at call sites.
class ProjectLanguagePair {
  const ProjectLanguagePair({
    required this.sourceLang,
    required this.targetLang,
  });

  static const ProjectLanguagePair defaults = ProjectLanguagePair(
    sourceLang: 'en_us',
    targetLang: 'ko_kr',
  );

  final String sourceLang;
  final String targetLang;

  /// Minecraft lang file name for the target profile (MVP: code + `.json`).
  String get outputFileName => '$targetLang.json';

  static Future<ProjectLanguagePair> fromDb(AppDatabase db) async {
    final meta = await db.select(db.projectMeta).getSingleOrNull();
    if (meta == null) return defaults;
    return ProjectLanguagePair(
      sourceLang: meta.sourceLangCode,
      targetLang: meta.targetLangCode,
    );
  }
}
