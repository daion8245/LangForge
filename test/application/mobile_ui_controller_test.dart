import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/application/mobile/mobile_ui_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  MobileUiState read() => container.read(mobileUiControllerProvider);
  MobileUiController notifier() =>
      container.read(mobileUiControllerProvider.notifier);

  test('starts on 파일 with nothing open', () {
    expect(read().tab, MobileTab.files);
    expect(read().sheet, isNull);
    expect(read().toast, isNull);
  });

  test('switching tabs closes whatever sheet was up', () {
    notifier().openEditSheet('entry-1');
    expect(read().sheet, MobileSheet.edit);

    notifier().selectTab(MobileTab.output);
    expect(read().tab, MobileTab.output);
    expect(read().sheet, isNull);
    expect(read().editEntryId, isNull);
  });

  test('closing a sheet clears the target it was opened on', () {
    notifier().openSourceSheet('ns-1');
    expect(read().sourceNamespaceId, 'ns-1');

    notifier().closeSheet();
    expect(read().sheet, isNull);
    expect(read().sourceNamespaceId, isNull);
  });

  test('a toast survives a tab change and is only cleared on dismiss', () {
    notifier().showToast('저장했습니다', '프로젝트를 저장했습니다.');
    notifier().selectTab(MobileTab.issues);
    expect(read().toast?.title, '저장했습니다');

    notifier().dismissToast();
    expect(read().toast, isNull);
  });

  test('showing a toast replaces the previous one', () {
    notifier().showToast('첫 번째', 'a');
    notifier().showToast('두 번째', 'b', isError: true);

    expect(read().toast?.title, '두 번째');
    expect(read().toast?.isError, isTrue);
  });

  test('goToEntry lands on the edit tab with the sheet open', () {
    notifier().selectTab(MobileTab.issues);
    notifier().goToEntry(tab: MobileTab.edit, entryId: 'entry-9');

    expect(read().tab, MobileTab.edit);
    expect(read().sheet, MobileSheet.edit);
    expect(read().editEntryId, 'entry-9');
  });
}
