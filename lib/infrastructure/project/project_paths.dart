import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where LangForge keeps its own files. See TECHNICAL.md 3.1.
abstract final class ProjectPaths {
  static const String projectExtension = '.lfproj';

  /// `%APPDATA%\LangForge` on Windows.
  ///
  /// The environment variable is preferred over `path_provider` because 3.1
  /// names this exact directory; `getApplicationSupportDirectory()` would add
  /// a company/product pair that the document does not describe.
  static Future<Directory> appDataDirectory() async {
    final appData = Platform.environment['APPDATA'];
    final base = appData != null && appData.isNotEmpty
        ? Directory(p.join(appData, 'LangForge'))
        : Directory(
            p.join((await getApplicationSupportDirectory()).path, 'LangForge'),
          );
    if (!base.existsSync()) base.createSync(recursive: true);
    return base;
  }

  static Future<File> registryFile() async {
    final dir = await appDataDirectory();
    return File(p.join(dir.path, 'registry.db'));
  }

  static Future<Directory> logsDirectory() async {
    final dir = await appDataDirectory();
    final logs = Directory(p.join(dir.path, 'logs'));
    if (!logs.existsSync()) logs.createSync(recursive: true);
    return logs;
  }

  /// Where the first-save dialog starts (AC-10.8).
  ///
  /// This only computes the path. The folder is created after the user has
  /// confirmed a location — never before, so declining the dialog leaves no
  /// directory behind.
  static Future<String> defaultProjectsDirectoryPath() async {
    final documents = await getApplicationDocumentsDirectory();
    return p.join(documents.path, 'LangForge Projects');
  }

  /// Turns an input file name into a project name (AC-10.9).
  static String projectNameFromInputFile(String inputFilePath) {
    final base = p.basenameWithoutExtension(inputFilePath).trim();
    return base.isEmpty ? 'Untitled Project' : base;
  }

  /// Adds `.lfproj` when the user typed a bare name.
  static String ensureProjectExtension(String path) {
    return p.extension(path).toLowerCase() == projectExtension
        ? path
        : '$path$projectExtension';
  }
}
