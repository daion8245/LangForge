import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/db_provider.dart';
import '../application/entries/entries_page_controller.dart';
import '../application/scan/scan_controller.dart';
import '../infrastructure/db/app_database.dart';
import '../infrastructure/db/row_mappers.dart';
import '../infrastructure/export/pack_icon_loader.dart';
import '../infrastructure/export/resource_pack_exporter.dart';
import '../presentation/editor/editor_shell.dart';
import '../presentation/empty/empty_project_view.dart';
import '../presentation/export/export_modal_view.dart';
import 'theme/lf_colors.dart';
import 'theme/lf_radii.dart';
import 'theme/lf_spacing.dart';
import 'theme/lf_typography.dart';

/// Shown in the exported report header.
const String appVersion = '0.1.0';

class LangForgeApp extends ConsumerWidget {
  const LangForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeData.dark().copyWith(
      extensions: [
        LfColors.dark,
        LfSpacing.standard,
        LfRadii.standard,
        LfTypography.standard,
      ],
    );

    return MaterialApp(
      title: 'LangForge',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDatabase db = ref.watch(appDatabaseProvider);
    final scanState = ref.watch(scanControllerProvider);
    final scanNotifier = ref.read(scanControllerProvider.notifier);

    return StreamBuilder<List<InputFile>>(
      stream: db.select(db.inputFiles).watch(),
      builder: (context, filesSnapshot) {
        final inputFiles = filesSnapshot.data ?? [];

        if (inputFiles.isEmpty && !scanState.isScanning) {
          return EmptyProjectView(
            onFilesSelected: (paths) => scanNotifier.addFiles(paths),
            onFolderSelected: (path) => scanNotifier.addDirectory(path),
          );
        }

        return StreamBuilder<List<Namespace>>(
          stream: db.select(db.namespaces).watch(),
          builder: (context, nsSnapshot) {
            final namespaces = nsSnapshot.data ?? [];

            return StreamBuilder<List<LanguageFile>>(
              stream: db.select(db.languageFiles).watch(),
              builder: (context, lfSnapshot) {
                final languageFiles = lfSnapshot.data ?? [];

                // Only the visible page is held in memory. A project can carry
                // tens of thousands of entries (AGENTS.md 5.6).
                final entriesPage =
                    ref.watch(entriesPageProvider).asData?.value ??
                    const <Entry>[];
                final totalCount =
                    ref.watch(entriesTotalCountProvider).asData?.value ?? 0;
                final statusCounts =
                    ref.watch(entryStatusCountsProvider).asData?.value ??
                    const <String, int>{};
                final viewState = ref.watch(entriesViewControllerProvider);
                final entriesNotifier = ref.read(
                  entriesViewControllerProvider.notifier,
                );

                return Builder(
                  builder: (context) {
                    return EditorShell(
                      inputFiles: inputFiles,
                      namespaces: namespaces,
                      languageFiles: languageFiles,
                      entries: entriesPage,
                      totalEntryCount: totalCount,
                      statusCounts: statusCounts,
                      statusFilter: viewState.statusFilter,
                      hasMoreEntries: entriesPage.length < totalCount,
                      onLoadMoreEntries: entriesNotifier.loadMore,
                      onStatusFilterChanged: entriesNotifier.setStatusFilter,
                      selectedNamespaceId: scanState.activeNamespaceId,
                      onSelectNamespace: (id) {
                        scanNotifier.setActiveNamespace(id);
                        entriesNotifier.selectNamespace(id);
                      },
                      onAddFiles: () async {
                        final result = await FilePicker.pickFiles(
                          allowMultiple: true,
                          type: FileType.custom,
                          allowedExtensions: ['jar', 'zip'],
                        );
                        if (result != null && result.paths.isNotEmpty) {
                          final validPaths = result.paths
                              .whereType<String>()
                              .toList();
                          await scanNotifier.addFiles(validPaths);
                        }
                      },
                      onAddFolder: () async {
                        final dir = await FilePicker.getDirectoryPath();
                        if (dir != null) {
                          await scanNotifier.addDirectory(dir);
                        }
                      },
                      onRescan: () async {},
                      onExport: () async {
                        final mcVersionsJsonStr = await rootBundle.loadString(
                          'assets/data/mc_versions.json',
                        );

                        // Bundled pack.png (TECHNICAL.md 8.1). Custom icons
                        // arrive with the project settings in Phase 6.
                        final packIcon = await PackIconLoader.load();

                        // Export is the one operation that legitimately needs
                        // every row. Read them once here rather than holding a
                        // full-table stream open for the whole session.
                        final allEntries = await db
                            .select(db.entries)
                            .get()
                            .then((rows) => rows.toDomain());
                        final domainNamespaces = namespaces.toDomain();

                        if (!context.mounted) return;

                        await showDialog<void>(
                          context: context,
                          builder: (modalContext) => ExportModalView(
                            namespaces: domainNamespaces,
                            entries: allEntries,
                            isTranslating: false,
                            mcVersionsJsonStr: mcVersionsJsonStr,
                            onExportConfirmed:
                                (
                                  formatOption,
                                  mcVersion,
                                  packFormat,
                                  options,
                                ) async {
                                  final outputDir =
                                      await FilePicker.getDirectoryPath() ??
                                      Directory.current.path;

                                  final format = switch (formatOption) {
                                    ExportFormatOption.zipPack =>
                                      ExportFormat.zipPack,
                                    ExportFormatOption.folderPack =>
                                      ExportFormat.folderPack,
                                    ExportFormatOption.pathJson =>
                                      ExportFormat.pathJson,
                                    ExportFormatOption.namespaceJson =>
                                      ExportFormat.namespaceJson,
                                  };

                                  try {
                                    final outputPath =
                                        await ResourcePackExporter.export(
                                          targetDirPath: outputDir,
                                          format: format,
                                          inputFiles: inputFiles.toDomain(),
                                          namespaces: domainNamespaces,
                                          entries: allEntries,
                                          packFormat: packFormat,
                                          providerName: 'Gemini',
                                          modelName: 'gemini-3.6-flash',
                                          sourceLangCode: 'en_us',
                                          targetLangCode: 'ko_kr',
                                          outputFileName: 'ko_kr.json',
                                          appVersion: appVersion,
                                          staleKeysByNamespace:
                                              scanState.staleKeysByNamespace,
                                          packIconBytes: packIcon,
                                        );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('내보내기 완료: $outputPath'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('내보내기 실패: $e')),
                                      );
                                    }
                                  }
                                },
                          ),
                        );
                      },
                      onCancelScan: scanNotifier.cancelScan,
                      onUpdateUserTranslation: (id, text) =>
                          scanNotifier.updateUserTranslation(id, text),
                      onResetEntryToWait: (id) =>
                          scanNotifier.resetEntryToWait(id),
                      onKeepSourceText: (id) => scanNotifier.keepSourceText(id),
                      isScanning: scanState.isScanning,
                      scanMessage: scanState.currentStatusMessage,
                      rejectedSummary: scanState.rejectedSummary,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
