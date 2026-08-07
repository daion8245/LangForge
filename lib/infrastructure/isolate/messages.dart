class FileScanRequest {
  final String filePath;
  final String kind; // jar | zip | directory

  const FileScanRequest({required this.filePath, required this.kind});
}

class DiscoveredNamespaceData {
  final String namespace;
  final String state; // ok | noSource | jsonError
  final String? errorMessage;
  final int? errorLine;
  final List<DiscoveredLangFileData> langFiles;

  const DiscoveredNamespaceData({
    required this.namespace,
    required this.state,
    this.errorMessage,
    this.errorLine,
    required this.langFiles,
  });
}

class DiscoveredLangFileData {
  final String rawCode;
  final String code; // normalized
  final String entryPath;
  final int keyCount;
  final String role; // source | existingTarget | other
  final Map<String, String> entries;
  final List<String> keyOrder;

  const DiscoveredLangFileData({
    required this.rawCode,
    required this.code,
    required this.entryPath,
    required this.keyCount,
    required this.role,
    required this.entries,
    required this.keyOrder,
  });
}

class FileScanResponse {
  final String filePath;
  final String originalName;
  final int sizeBytes;
  final String sha256;
  final bool isOk;
  final String? rejectReason;
  final List<DiscoveredNamespaceData> namespaces;

  const FileScanResponse({
    required this.filePath,
    required this.originalName,
    required this.sizeBytes,
    required this.sha256,
    required this.isOk,
    this.rejectReason,
    this.namespaces = const [],
  });
}
