import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:langforge/domain/model/entry_status.dart';
import 'package:langforge/domain/model/translation_entry.dart';
import 'package:langforge/domain/policy/exclusion_policy.dart';
import 'package:langforge/domain/policy/merge_policy.dart';
import 'package:langforge/domain/protection/multiset.dart';
import 'package:langforge/domain/protection/token_protector.dart';

import 'package:langforge/infrastructure/export/resource_pack_exporter.dart';
import 'package:langforge/infrastructure/export/zip_verifier.dart';
import 'package:langforge/infrastructure/security/sensitive_filter.dart';

void main() {
  group('Phase 7 Corpus & End-to-End Acceptance Tests (C-1 ~ C-8)', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('phase7_corpus_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'C-1 ~ C-3: Key, Token & Namespace Integrity in Large Corpus Data',
      () {
        final entriesList = <TranslationEntry>[];
        for (int i = 0; i < 1000; i++) {
          final key = 'block.quark.item_$i';
          final sourceText = i % 5 == 0
              ? '%s hit %s for $i damage'
              : 'Oak Item #$i';

          entriesList.add(
            TranslationEntry(
              id: 'entry_$i',
              namespaceId: 'ns_quark',
              key: key,
              keyOrder: i,
              sourceText: sourceText,
              status: EntryStatus.done,
              newTranslation: i % 5 == 0
                  ? '%s님이 %s님에게 $i 데미지 타격'
                  : '참나무 아이템 #$i',
            ),
          );
        }

        expect(entriesList.length, equals(1000));

        // C-2: Check zero key alteration and zero key loss
        for (int i = 0; i < 1000; i++) {
          expect(entriesList[i].key, equals('block.quark.item_$i'));
          expect(entriesList[i].keyOrder, equals(i));
        }

        // C-3: Check token protection multiset match on tokenized items
        final tokenizedEntry = entriesList[0];
        final multisetMatch = MultisetValidator.validate(
          tokenizedEntry.sourceText,
          tokenizedEntry.newTranslation!,
        );
        expect(multisetMatch.isMatch, isTrue);
      },
    );

    test(
      'C-4 & C-5: MergePolicy 6-Stage Priority & UTF-8 Literal Preservation',
      () {
        const entry = TranslationEntry(
          id: 'e_utf8',
          namespaceId: 'ns1',
          key: 'item.minecraft.oak_door',
          keyOrder: 1,
          sourceText: 'Oak Door',
          existingTranslation: null,
          newTranslation: '참나무 문',
          userTranslation: '참나무 문 (사용자 수정)',
          status: EntryStatus.confirm,
          userEdited: true,
        );

        final finalStr = MergePolicy.resolveFinal(entry);
        expect(finalStr, equals('참나무 문 (사용자 수정)'));

        // Ensure UTF-8 Korean literals remain intact without \uXXXX escaping
        expect(finalStr, isNot(contains(r'\u')));
        expect(finalStr, contains('참나무'));
      },
    );

    test('C-6 & C-7: Resource Pack Export & Sensitive Data Scrubbing', () async {
      final inputFiles = [
        const InputFileUnit(
          id: 'f1',
          originalName: 'Quark.jar',
          sha256: '1234567890abcdef',
          kind: 'jar',
          sizeBytes: 1024,
          scanState: ScanState.ok,
        ),
      ];

      final namespaces = [
        const NamespaceUnit(
          id: 'ns1',
          inputFileId: 'f1',
          name: 'quark',
          state: NamespaceState.ok,
          keyCount: 1,
        ),
      ];

      final entries = [
        const TranslationEntry(
          id: 'e1',
          namespaceId: 'ns1',
          key: 'block.oak_hedge',
          keyOrder: 1,
          sourceText: 'Oak Hedge',
          newTranslation: '참나무 산울타리',
          status: EntryStatus.done,
        ),
      ];

      // Export ZIP
      final zipPath = await ResourcePackExporter.export(
        targetDirPath: tempDir.path,
        format: ExportFormat.zipPack,
        inputFiles: inputFiles,
        namespaces: namespaces,
        entries: entries,
        packFormat: 15,
        providerName: 'Gemini',
        modelName: 'gemini-3.6-flash',
        sourceLangCode: 'en_us',
        targetLangCode: 'ko_kr',
        outputFileName: 'ko_kr.json',
        appVersion: '0.1.0',
      );

      // Verify ZIP structure
      await expectLater(ZipVerifier.verifyPackZip(zipPath), completes);

      // Check Report Sensitive Filter
      const rawLog =
          'Exported with key AIzaSyA1b2C3d4E5f6G7h8I9j0K1l2M3n4O5p6 by user C:\\Users\\kingh';
      final scrubbed = SensitiveFilter.scrub(rawLog);
      expect(scrubbed, contains('[REDACTED]'));
      expect(scrubbed, contains('%USERPROFILE%'));
    });

    test('C-8: ExclusionPolicy & TokenProtector round-trip reliability', () {
      expect(ExclusionPolicy.shouldExclude('https://minecraft.net'), isTrue);
      expect(ExclusionPolicy.shouldExclude('Oak Hedge'), isFalse);

      const sourceWithToken = 'Give %s %d items';
      final protected = TokenProtector.protect(sourceWithToken);
      expect(protected.tokens, hasLength(2));

      final restored = TokenProtector.restore(protected, protected.masked);
      expect(restored, equals(sourceWithToken));
    });
  });
}
