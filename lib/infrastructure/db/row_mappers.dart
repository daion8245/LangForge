import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';
import 'app_database.dart';

/// Converts Drift rows into the pure domain models.
///
/// This is the only place that knows both shapes. `domain/` must never import
/// Drift — see TECHNICAL.md 2.1.
extension EntryRowMapper on Entry {
  TranslationEntry toDomain() {
    return TranslationEntry(
      id: id,
      namespaceId: namespaceId,
      key: key,
      keyOrder: keyOrder,
      sourceText: sourceText,
      existingTranslation: existingTranslation,
      newTranslation: newTranslation,
      userTranslation: userTranslation,
      userEdited: userEdited,
      status: EntryStatus.fromWire(status),
    );
  }
}

extension NamespaceRowMapper on Namespace {
  NamespaceUnit toDomain() {
    return NamespaceUnit(
      id: id,
      inputFileId: inputFileId,
      name: name,
      state: NamespaceState.fromWire(state),
      excluded: excluded,
      selected: selected,
      keyCount: keyCount,
      errorMessage: errorMessage,
      errorLine: errorLine,
    );
  }
}

extension InputFileRowMapper on InputFile {
  InputFileUnit toDomain() {
    return InputFileUnit(
      id: id,
      originalName: originalName,
      kind: kind,
      sizeBytes: sizeBytes,
      sha256: sha256,
      scanState: ScanState.fromWire(scanState),
    );
  }
}

extension EntryRowListMapper on List<Entry> {
  List<TranslationEntry> toDomain() => map((e) => e.toDomain()).toList();
}

extension NamespaceRowListMapper on List<Namespace> {
  List<NamespaceUnit> toDomain() => map((e) => e.toDomain()).toList();
}

extension InputFileRowListMapper on List<InputFile> {
  List<InputFileUnit> toDomain() => map((e) => e.toDomain()).toList();
}
