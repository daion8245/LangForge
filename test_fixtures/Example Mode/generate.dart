// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

void main() {
  final outputDir = Directory(p.join('test_fixtures', 'Example Mode'));
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  print('Generating test fixtures in: ${outputDir.path}');

  _generateMultiNsJar(outputDir);
  _generateLegacyJar(outputDir);
  _generateBrokenJar(outputDir);

  print('Successfully generated 3 test JARs.');
}

void _generateMultiNsJar(Directory dir) {
  final archive = Archive();

  // Manifest
  final manifest =
      'Manifest-Version: 1.0\r\nCreated-By: LangForge Fixture Generator\r\n';
  _addArchiveFile(archive, 'META-INF/MANIFEST.MF', utf8.encode(manifest));

  // exalpha en_us.json
  final exalphaEn = {
    'block.exalpha.oak_hedge': 'Oak Hedge',
    'item.exalpha.ancient_tome': 'Ancient Tome',
    'gui.exalpha.settings': 'Settings',
    'tooltip.exalpha.damage': 'Deals %1\$.1f damage.',
    'death.exalpha.escape': '%1\$s died whilst trying to escape %2\$s',
    'chat.exalpha.hit': '%s hit %s for %d damage',
    'msg.exalpha.count': '%02d items',
    'msg.exalpha.percent': 'Progress: 50%% complete',
    'msg.exalpha.newline': 'Line one\nLine two',
    'msg.exalpha.quote': 'He said "hello"',
    'msg.exalpha.backslash': r'Path: C:\mods',
    'msg.exalpha.color': '§aReady§r',
    'msg.exalpha.hex': '§x§F§F§A§A§0§0Ready to load§r',
    'msg.exalpha.brace': 'Module: {0} ({1})',
    'msg.exalpha.named': 'Welcome, {name}!',
    'msg.exalpha.double_brace': 'Welcome, {{name}}!',
    'msg.exalpha.shell': r'Saved ${player} profile',
    'msg.exalpha.empty': '',
    'msg.exalpha.url': 'https://example.com/docs',
    'msg.exalpha.resource': 'minecraft:stone',
    'msg.exalpha.numeric': '1.20.1',
    'msg.exalpha.tokenonly': '%s',
  };
  _addArchiveFile(
    archive,
    'assets/exalpha/lang/en_us.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exalphaEn)),
  );

  // exalpha ko_kr.json (partial + one mismatched token count for confirm test)
  final exalphaKo = {
    'block.exalpha.oak_hedge': '참나무 산울타리',
    'gui.exalpha.settings': '설정',
    'death.exalpha.escape':
        '%1\$s님이 탈출하려다 사망했습니다', // missing %2$s to trigger confirm validation
  };
  _addArchiveFile(
    archive,
    'assets/exalpha/lang/ko_kr.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exalphaKo)),
  );

  // exalpha ja_jp.json
  final exalphaJa = {'block.exalpha.oak_hedge': 'オークの生垣'};
  _addArchiveFile(
    archive,
    'assets/exalpha/lang/ja_jp.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exalphaJa)),
  );

  // exbeta en_us.json
  final exbetaEn = {'block.exbeta.copper_pipe': 'Copper Pipe'};
  _addArchiveFile(
    archive,
    'assets/exbeta/lang/en_us.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exbetaEn)),
  );

  // exgamma en_us.json
  final exgammaEn = {'item.exgamma.ruby_sword': 'Ruby Sword'};
  _addArchiveFile(
    archive,
    'assets/exgamma/lang/en_us.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exgammaEn)),
  );

  // exgamma ko_kr.json
  final exgammaKo = {'item.exgamma.ruby_sword': '루비 검'};
  _addArchiveFile(
    archive,
    'assets/exgamma/lang/ko_kr.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exgammaKo)),
  );

  final zipBytes = ZipEncoder().encode(archive);
  final file = File(p.join(dir.path, 'ExampleMultiNs-1.0.jar'));
  file.writeAsBytesSync(zipBytes);
}

void _generateLegacyJar(Directory dir) {
  final archive = Archive();

  // exlegacy (no en_us, has en_gb)
  final exlegacyGb = {
    'item.exlegacy.armour': 'Armour',
    'gui.exlegacy.colour': 'Colour Settings',
  };
  _addArchiveFile(
    archive,
    'assets/exlegacy/lang/en_gb.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exlegacyGb)),
  );

  final exlegacyDe = {'item.exlegacy.armour': 'Rüstung'};
  _addArchiveFile(
    archive,
    'assets/exlegacy/lang/de_de.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exlegacyDe)),
  );

  // exlegacyok (normal)
  final exlegacyOkEn = {'block.exlegacyok.stone': 'Legacy Stone'};
  _addArchiveFile(
    archive,
    'assets/exlegacyok/lang/en_us.json',
    utf8.encode(const JsonEncoder.withIndent('  ').convert(exlegacyOkEn)),
  );

  final zipBytes = ZipEncoder().encode(archive);
  final file = File(p.join(dir.path, 'ExampleLegacy-2.1.jar'));
  file.writeAsBytesSync(zipBytes);
}

void _generateBrokenJar(Directory dir) {
  final archive = Archive();

  // exbroken en_us.json with missing comma syntax error
  final brokenJsonStr = '''
{
  "item.exbroken.valid": "Valid Item"
  "item.exbroken.broken": "Broken Item"
}
''';
  _addArchiveFile(
    archive,
    'assets/exbroken/lang/en_us.json',
    utf8.encode(brokenJsonStr),
  );

  final zipBytes = ZipEncoder().encode(archive);
  final file = File(p.join(dir.path, 'ExampleBroken-0.9.jar'));
  file.writeAsBytesSync(zipBytes);
}

void _addArchiveFile(Archive archive, String path, List<int> bytes) {
  final file = ArchiveFile(path, bytes.length, bytes);
  archive.addFile(file);
}
