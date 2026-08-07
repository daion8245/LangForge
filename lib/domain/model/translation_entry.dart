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
    this.glossaryTranslation,
    this.reviewedCacheTranslation,
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

  /// Value produced by a translation provider (or auto-cache) in this project.
  final String? newTranslation;

  /// Value the user typed. Outranks everything else.
  final String? userTranslation;

  /// Exact glossary hit. MergePolicy step 3. [1.0]
  final String? glossaryTranslation;

  /// `reviewed` / `userEdited` cache only. MergePolicy step 4. [1.0]
  final String? reviewedCacheTranslation;

  final bool userEdited;

  final EntryStatus status;

  TranslationEntry copyWith({
    String? existingTranslation,
    String? newTranslation,
    String? userTranslation,
    String? glossaryTranslation,
    String? reviewedCacheTranslation,
    bool? userEdited,
    EntryStatus? status,
  }) {
    return TranslationEntry(
      id: id,
      namespaceId: namespaceId,
      key: key,
      keyOrder: keyOrder,
      sourceText: sourceText,
      existingTranslation: existingTranslation ?? this.existingTranslation,
      newTranslation: newTranslation ?? this.newTranslation,
      userTranslation: userTranslation ?? this.userTranslation,
      glossaryTranslation: glossaryTranslation ?? this.glossaryTranslation,
      reviewedCacheTranslation:
          reviewedCacheTranslation ?? this.reviewedCacheTranslation,
      userEdited: userEdited ?? this.userEdited,
      status: status ?? this.status,
    );
  }
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
