import 'entry_status.dart';

/// One translatable key/value pair, independent of how it is stored.
///
/// The three translation fields are deliberately nullable and are **not**
/// collapsed to empty strings. An empty string is a real, deliberate value —
/// see [MergePolicy] and TECHNICAL.md 7.1.
class TranslationEntry {
  const TranslationEntry({
    required this.id,
    required this.namespaceId,
    required this.key,
    required this.keyOrder,
    required this.sourceText,
    required this.status,
    this.existingTranslation,
    this.newTranslation,
    this.userTranslation,
    this.userEdited = false,
  });

  final String id;
  final String namespaceId;

  /// Never modified, never sent to a translation provider.
  final String key;

  /// Position of [key] in the original JSON. Preserved on export.
  final int keyOrder;

  final String sourceText;

  /// Value found in the input file's target language JSON.
  final String? existingTranslation;

  /// Value produced by a translation provider in this project.
  final String? newTranslation;

  /// Value the user typed. Outranks everything else.
  final String? userTranslation;

  final bool userEdited;

  final EntryStatus status;
}

/// One `assets/{name}/lang` unit inside an input file.
class NamespaceUnit {
  const NamespaceUnit({
    required this.id,
    required this.inputFileId,
    required this.name,
    required this.state,
    this.excluded = false,
    this.selected = true,
    this.keyCount = 0,
    this.errorMessage,
    this.errorLine,
  });

  final String id;
  final String inputFileId;
  final String name;
  final NamespaceState state;
  final bool excluded;
  final bool selected;
  final int keyCount;
  final String? errorMessage;
  final int? errorLine;
}

/// A JAR, ZIP, or folder the user added.
class InputFileUnit {
  const InputFileUnit({
    required this.id,
    required this.originalName,
    required this.kind,
    required this.sizeBytes,
    required this.sha256,
    required this.scanState,
  });

  final String id;
  final String originalName;

  /// `jar` | `zip` | `directory`.
  final String kind;

  final int sizeBytes;
  final String sha256;
  final ScanState scanState;
}
