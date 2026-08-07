/// The release version, written into project files and the export report.
///
/// Kept at the root so every layer can read it without an inward dependency.
/// Must match `version:` in `pubspec.yaml` — TECHNICAL.md 14.3 checks both.
const String appVersion = '1.0.0';
