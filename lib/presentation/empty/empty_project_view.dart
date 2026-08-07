import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../common/lf_button.dart';

class EmptyProjectView extends StatefulWidget {
  const EmptyProjectView({
    super.key,
    required this.onFilesSelected,
    required this.onFolderSelected,
  });

  final ValueChanged<List<String>> onFilesSelected;
  final ValueChanged<String> onFolderSelected;

  @override
  State<EmptyProjectView> createState() => _EmptyProjectViewState();
}

class _EmptyProjectViewState extends State<EmptyProjectView> {
  bool _isDraggingOver = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jar', 'zip'],
    );

    if (result != null && result.paths.isNotEmpty) {
      final validPaths = result.paths.whereType<String>().toList();
      if (validPaths.isNotEmpty) {
        widget.onFilesSelected(validPaths);
      }
    }
  }

  Future<void> _pickFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null && path.isNotEmpty) {
      widget.onFolderSelected(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDraggingOver = true),
      onDragExited: (_) => setState(() => _isDraggingOver = false),
      onDragDone: (DropDoneDetails details) {
        setState(() => _isDraggingOver = false);
        final paths = details.files.map((f) => f.path).toList();
        if (paths.isNotEmpty) {
          widget.onFilesSelected(paths);
        }
      },
      child: Scaffold(
        backgroundColor: colors.bgBase,
        body: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(maxWidth: 520),
            padding: EdgeInsets.all(spacing.space11),
            decoration: BoxDecoration(
              color: _isDraggingOver ? colors.bgSelected : colors.bgSurface,
              borderRadius: radii.r4xl,
              border: Border.all(
                color: _isDraggingOver ? colors.accent : colors.borderDashed,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.uploadCloud,
                  size: 48,
                  color: _isDraggingOver ? colors.accent : colors.textMuted,
                ),
                SizedBox(height: spacing.space8),
                Text(
                  '마인크래프트 모드 JAR 또는 리소스팩 추가',
                  style: typography.title.copyWith(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.space5),
                Text(
                  '파일을 이곳으로 드래그 앤 드롭하거나 아래 버튼으로 선택하세요.\n'
                  'JAR, ZIP 또는 unpacked 모드 폴더를 지원합니다.',
                  style: typography.bodySm.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing.space10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LfButton(
                      onPressed: _pickFiles,
                      label: 'JAR / ZIP 파일 선택',
                      icon: const Icon(LucideIcons.filePlus, size: 16),
                      style: LfButtonStyle.primary,
                    ),
                    SizedBox(width: spacing.space6),
                    LfButton(
                      onPressed: _pickFolder,
                      label: 'mods 폴더 선택',
                      icon: const Icon(LucideIcons.folderPlus, size: 16),
                      style: LfButtonStyle.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
