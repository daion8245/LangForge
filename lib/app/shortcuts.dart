import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard map of EXPERIENCE.md 8.
///
/// Intents are declared rather than wired straight to callbacks so the same
/// action can also be reached from the file menu, and so a future preferences
/// screen can remap them in one place.
class AddFilesIntent extends Intent {
  const AddFilesIntent();
}

class AddFolderIntent extends Intent {
  const AddFolderIntent();
}

class RescanIntent extends Intent {
  const RescanIntent();
}

class RunTranslationIntent extends Intent {
  const RunTranslationIntent();
}

class SaveProjectIntent extends Intent {
  const SaveProjectIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class DismissIntent extends Intent {
  const DismissIntent();
}

class NextNamespaceIntent extends Intent {
  const NextNamespaceIntent();
}

/// Wraps the editor in the application-wide shortcut map.
class LangForgeShortcuts extends StatelessWidget {
  const LangForgeShortcuts({
    super.key,
    required this.child,
    required this.onAddFiles,
    required this.onAddFolder,
    required this.onRescan,
    required this.onStartTranslation,
    required this.onSave,
    required this.onExport,
    required this.onFocusSearch,
    required this.onEscape,
    required this.onNextNamespace,
  });

  final Widget child;
  final Future<void> Function() onAddFiles;
  final Future<void> Function() onAddFolder;
  final Future<void> Function() onRescan;
  final VoidCallback onStartTranslation;
  final Future<void> Function() onSave;
  final VoidCallback onExport;
  final VoidCallback onFocusSearch;
  final VoidCallback onEscape;
  final VoidCallback onNextNamespace;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyO, control: true):
            AddFilesIntent(),
        SingleActivator(LogicalKeyboardKey.keyO, control: true, shift: true):
            AddFolderIntent(),
        SingleActivator(LogicalKeyboardKey.keyR, control: true, shift: true):
            RescanIntent(),
        SingleActivator(LogicalKeyboardKey.keyR, control: true):
            RunTranslationIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true):
            SaveProjectIntent(),
        SingleActivator(LogicalKeyboardKey.keyE, control: true): ExportIntent(),
        SingleActivator(LogicalKeyboardKey.keyF, control: true):
            FocusSearchIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        SingleActivator(LogicalKeyboardKey.tab, control: true):
            NextNamespaceIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          AddFilesIntent: CallbackAction<AddFilesIntent>(
            onInvoke: (_) => onAddFiles(),
          ),
          AddFolderIntent: CallbackAction<AddFolderIntent>(
            onInvoke: (_) => onAddFolder(),
          ),
          RescanIntent: CallbackAction<RescanIntent>(
            onInvoke: (_) => onRescan(),
          ),
          RunTranslationIntent: CallbackAction<RunTranslationIntent>(
            onInvoke: (_) {
              onStartTranslation();
              return null;
            },
          ),
          SaveProjectIntent: CallbackAction<SaveProjectIntent>(
            onInvoke: (_) => onSave(),
          ),
          ExportIntent: CallbackAction<ExportIntent>(
            onInvoke: (_) {
              onExport();
              return null;
            },
          ),
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (_) {
              onFocusSearch();
              return null;
            },
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              onEscape();
              return null;
            },
          ),
          NextNamespaceIntent: CallbackAction<NextNamespaceIntent>(
            onInvoke: (_) {
              onNextNamespace();
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
