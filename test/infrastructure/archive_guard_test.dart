import 'package:flutter_test/flutter_test.dart';
import 'package:langforge/infrastructure/archive/archive_guard.dart';

void main() {
  group('ArchiveGuard & isSafeEntryPath Tests', () {
    test('Allows safe relative entry paths', () {
      expect(isSafeEntryPath('assets/quark/lang/en_us.json'), isTrue);
      expect(isSafeEntryPath('META-INF/MANIFEST.MF'), isTrue);
      expect(isSafeEntryPath('foo/bar/baz.png'), isTrue);
    });

    test('Rejects Zip Slip path traversal attempts', () {
      expect(isSafeEntryPath('../evil.txt'), isFalse);
      expect(isSafeEntryPath('assets/../../etc/passwd'), isFalse);
      expect(isSafeEntryPath('foo/bar/../baz.json'), isFalse);
    });

    test(
      'Rejects absolute, drive letter, UNC, and control character paths',
      () {
        expect(isSafeEntryPath('/etc/passwd'), isFalse);
        expect(isSafeEntryPath(r'C:\Windows\System32\cmd.exe'), isFalse);
        expect(isSafeEntryPath('//unc/share/file.txt'), isFalse);
        expect(isSafeEntryPath('assets/quark\x00/lang/en_us.json'), isFalse);
      },
    );
  });
}
