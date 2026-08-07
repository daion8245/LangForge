import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four bottom tabs of DESIGN.md 6.3.
enum MobileTab {
  files('파일'),
  edit('편집'),
  issues('문제'),
  output('출력');

  const MobileTab(this.label);

  final String label;
}

/// The three bottom sheets of ROADMAP 13.3.
enum MobileSheet { edit, source, settings }

/// One toast (ROADMAP 13.7).
///
/// Toasts are not a log: only the newest one is on screen, and showing a new
/// one replaces whatever was there.
class MobileToast {
  const MobileToast({
    required this.title,
    required this.body,
    this.isError = false,
  });

  final String title;
  final String body;
  final bool isError;
}

class MobileUiState {
  const MobileUiState({
    this.tab = MobileTab.files,
    this.sheet,
    this.editEntryId,
    this.sourceNamespaceId,
    this.toast,
  });

  final MobileTab tab;

  /// Null when no sheet is up. The scrim is drawn on exactly this condition.
  final MobileSheet? sheet;

  /// Entry the 편집 sheet is open on.
  final String? editEntryId;

  /// Namespace the 원본 지정 sheet is open on.
  final String? sourceNamespaceId;

  final MobileToast? toast;

  MobileUiState copyWith({
    MobileTab? tab,
    MobileSheet? sheet,
    String? editEntryId,
    String? sourceNamespaceId,
    MobileToast? toast,
    bool clearSheet = false,
    bool clearToast = false,
  }) {
    return MobileUiState(
      tab: tab ?? this.tab,
      sheet: clearSheet ? null : (sheet ?? this.sheet),
      editEntryId: clearSheet ? null : (editEntryId ?? this.editEntryId),
      sourceNamespaceId: clearSheet
          ? null
          : (sourceNamespaceId ?? this.sourceNamespaceId),
      toast: clearToast ? null : (toast ?? this.toast),
    );
  }
}

/// Navigation state the mobile shell owns: which tab, which sheet, which toast.
///
/// Deliberately separate from the domain controllers. Nothing here is saved to
/// the project, and the desktop shell never reads it.
class MobileUiController extends Notifier<MobileUiState> {
  @override
  MobileUiState build() => const MobileUiState();

  /// Switching tabs always dismisses the sheet — a sheet belongs to the tab it
  /// was opened from, and leaving it up over a different tab reads as a bug.
  void selectTab(MobileTab tab) {
    state = state.copyWith(tab: tab, clearSheet: true);
  }

  void openEditSheet(String entryId) {
    state = state.copyWith(sheet: MobileSheet.edit, editEntryId: entryId);
  }

  void openSourceSheet(String namespaceId) {
    state = state.copyWith(
      sheet: MobileSheet.source,
      sourceNamespaceId: namespaceId,
    );
  }

  void openSettingsSheet() {
    state = state.copyWith(sheet: MobileSheet.settings);
  }

  void closeSheet() => state = state.copyWith(clearSheet: true);

  void showToast(String title, String body, {bool isError = false}) {
    state = state.copyWith(
      toast: MobileToast(title: title, body: body, isError: isError),
    );
  }

  void dismissToast() => state = state.copyWith(clearToast: true);

  /// Jumps straight to an entry from the 문제 tab (AC-7.7).
  void goToEntry({required MobileTab tab, required String entryId}) {
    state = MobileUiState(
      tab: tab,
      sheet: MobileSheet.edit,
      editEntryId: entryId,
      toast: state.toast,
    );
  }
}

final mobileUiControllerProvider =
    NotifierProvider<MobileUiController, MobileUiState>(MobileUiController.new);
