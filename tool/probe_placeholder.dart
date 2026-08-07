// Measures whether each translation engine preserves TokenProtector
// placeholders (U+2063 LF<n> U+2063) through a round trip.
//
// Phase 8 / TECHNICAL.md Q1. Run from the project root:
//
//   dart run tool/probe_placeholder.dart           # dry-run (no network)
//   dart run tool/probe_placeholder.dart --live    # call providers with keys
//
// Credentials are read from the environment only — never from argv or files:
//
//   LANGFORGE_GEMINI_API_KEY
//   LANGFORGE_DEEPL_API_KEY
//   LANGFORGE_GOOGLE_API_KEY
//   LANGFORGE_PAPAGO_CLIENT_ID
//   LANGFORGE_PAPAGO_CLIENT_SECRET
//
// Writes a markdown report to tool/probe_placeholder_results.md (gitignored
// content is fine to overwrite; the committed stub stays "not measured").

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:langforge/domain/protection/token_protector.dart';
import 'package:langforge/domain/provider/translation_error.dart';
import 'package:langforge/domain/provider/translation_provider.dart';
import 'package:langforge/infrastructure/provider/deepl_provider.dart';
import 'package:langforge/infrastructure/provider/gemini_provider.dart';
import 'package:langforge/infrastructure/provider/google_provider.dart';
import 'package:langforge/infrastructure/provider/papago_provider.dart';
import 'package:langforge/infrastructure/provider/provider_definition.dart';
import 'package:langforge/infrastructure/security/sensitive_filter.dart';

// Do not import ProviderCatalog — it pulls Flutter's rootBundle and breaks
// plain `dart run` outside the Flutter tool chain.

/// Minecraft-like UI strings covering the token families in token_pattern.dart.
const List<String> probeFixtures = [
  'Hello, %s!',
  'You have %d lives left',
  'Welcome, %1\$s — score %2\$d',
  'Color §aGreen§r reset',
  'Hex §x§F§F§A§A§0§0Custom',
  'Literal percent %% done',
  'Named {player} joined',
  'Double {{player_name}} brace',
  'Shell-style \${count} items',
  'Mixed %s and {item}',
  'Format §e%s§r collected',
  'Escaped \\%s stays literal',
  "It's a %s with & ampersand",
  'Tooltip: Hold §bShift§r',
  'Cost: %1\$s emeralds',
  'Progress %d%% complete',
  'Keybind [%s]',
  'Empty braces {} nearby',
  'Multi %s %s %s args',
  'Ender §5%s§r pearl',
];

const _resultsPath = 'tool/probe_placeholder_results.md';

Future<void> main(List<String> args) async {
  final live = args.contains('--live');
  final definitions = _loadDefinitions();

  final providers = <_ProbeTarget>[
    _ProbeTarget(
      id: 'gemini',
      envReady: () => _env('LANGFORGE_GEMINI_API_KEY').isNotEmpty,
      auth: () => AuthValues({'apiKey': _env('LANGFORGE_GEMINI_API_KEY')}),
      build: (def, client) => GeminiProvider(definition: def, client: client),
    ),
    _ProbeTarget(
      id: 'deepl',
      envReady: () => _env('LANGFORGE_DEEPL_API_KEY').isNotEmpty,
      auth: () => AuthValues({'apiKey': _env('LANGFORGE_DEEPL_API_KEY')}),
      build: (def, client) => DeepLProvider(definition: def, client: client),
    ),
    _ProbeTarget(
      id: 'google',
      envReady: () => _env('LANGFORGE_GOOGLE_API_KEY').isNotEmpty,
      auth: () => AuthValues({'apiKey': _env('LANGFORGE_GOOGLE_API_KEY')}),
      build: (def, client) => GoogleProvider(definition: def, client: client),
    ),
    _ProbeTarget(
      id: 'papago',
      envReady: () =>
          _env('LANGFORGE_PAPAGO_CLIENT_ID').isNotEmpty &&
          _env('LANGFORGE_PAPAGO_CLIENT_SECRET').isNotEmpty,
      auth: () => AuthValues({
        'clientId': _env('LANGFORGE_PAPAGO_CLIENT_ID'),
        'clientSecret': _env('LANGFORGE_PAPAGO_CLIENT_SECRET'),
      }),
      build: (def, client) => PapagoProvider(definition: def, client: client),
    ),
  ];

  stdout.writeln(
    live
        ? 'probe_placeholder — LIVE (providers with env keys only)'
        : 'probe_placeholder — DRY-RUN (no network). Pass --live to call APIs.',
  );
  stdout.writeln('fixtures: ${probeFixtures.length}');
  stdout.writeln('');

  final rows = <_ProviderProbeRow>[];
  for (final target in providers) {
    final definition = definitions[target.id];
    if (definition == null) {
      stderr.writeln('providers.json missing entry for ${target.id}');
      exitCode = 1;
      continue;
    }
    final row = await _probeProvider(target, definition, live: live);
    rows.add(row);
    _printRow(row);
  }

  final report = _renderReport(rows, live: live);
  File(_resultsPath).writeAsStringSync(report);
  stdout.writeln('');
  stdout.writeln('Wrote $_resultsPath');
  stdout.writeln(
    'Copy the summary table into docs/TECHNICAL.md Q1 when live results exist.',
  );
}

Map<String, ProviderDefinition> _loadDefinitions() {
  final source = File('assets/data/providers.json').readAsStringSync();
  final decoded = jsonDecode(source) as Map<String, dynamic>;
  final list = (decoded['providers'] as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(ProviderDefinition.fromJson);
  return {for (final def in list) def.id: def};
}

Future<_ProviderProbeRow> _probeProvider(
  _ProbeTarget target,
  ProviderDefinition definition, {
  required bool live,
}) async {
  final protected = [
    for (final source in probeFixtures) TokenProtector.protect(source),
  ];
  final withTokens = protected.where((p) => p.tokens.isNotEmpty).length;

  if (!live) {
    return _ProviderProbeRow(
      providerId: target.id,
      status: _ProbeStatus.skippedDryRun,
      fixtureCount: probeFixtures.length,
      withTokens: withTokens,
      passed: 0,
      failed: 0,
      notes: 'dry-run — placeholders prepared, no API call',
      failures: const [],
    );
  }

  if (!target.envReady()) {
    return _ProviderProbeRow(
      providerId: target.id,
      status: _ProbeStatus.skippedNoKey,
      fixtureCount: probeFixtures.length,
      withTokens: withTokens,
      passed: 0,
      failed: 0,
      notes: 'missing env credentials',
      failures: const [],
    );
  }

  final client = http.Client();
  try {
    final provider = target.build(definition, client);
    final auth = target.auth();
    var passed = 0;
    final failures = <_FixtureFailure>[];

    // Papago accepts one text per request; others take a batch.
    final batchSize = provider.limits.maxTextsPerRequest.clamp(1, 20);

    for (var offset = 0; offset < protected.length; offset += batchSize) {
      final slice = protected.sublist(
        offset,
        (offset + batchSize).clamp(0, protected.length),
      );
      final masked = [for (final p in slice) p.masked];

      List<String> translated;
      try {
        translated = await provider.translate(
          TranslationRequest(
            texts: masked,
            sourceCode: 'en_us',
            targetCode: 'ko_kr',
            model: provider.models.isEmpty ? null : provider.models.first,
            auth: auth,
            cancel: CancellationToken(),
          ),
        );
      } on TranslationError catch (error) {
        for (var i = 0; i < slice.length; i++) {
          failures.add(
            _FixtureFailure(
              index: offset + i,
              source: probeFixtures[offset + i],
              reason: 'api: ${error.message}',
            ),
          );
        }
        continue;
      }

      if (translated.length != slice.length) {
        for (var i = 0; i < slice.length; i++) {
          failures.add(
            _FixtureFailure(
              index: offset + i,
              source: probeFixtures[offset + i],
              reason:
                  'count mismatch: asked ${slice.length}, got ${translated.length}',
            ),
          );
        }
        continue;
      }

      for (var i = 0; i < slice.length; i++) {
        final restored = TokenProtector.restore(slice[i], translated[i]);
        if (restored == null) {
          failures.add(
            _FixtureFailure(
              index: offset + i,
              source: probeFixtures[offset + i],
              reason: 'placeholder lost or corrupted',
              translatedSample: _clip(translated[i]),
            ),
          );
        } else {
          passed++;
        }
      }
    }

    return _ProviderProbeRow(
      providerId: target.id,
      status: failures.isEmpty ? _ProbeStatus.pass : _ProbeStatus.fail,
      fixtureCount: probeFixtures.length,
      withTokens: withTokens,
      passed: passed,
      failed: failures.length,
      notes: failures.isEmpty
          ? 'all restore() calls succeeded'
          : '${failures.length} fixture(s) failed restore()',
      failures: failures,
    );
  } finally {
    client.close();
  }
}

void _printRow(_ProviderProbeRow row) {
  final rate = row.fixtureCount == 0
      ? '—'
      : row.status == _ProbeStatus.skippedDryRun ||
            row.status == _ProbeStatus.skippedNoKey
      ? '—'
      : '${row.passed}/${row.fixtureCount}';
  stdout.writeln(
    SensitiveFilter.scrub(
      '${row.providerId.padRight(8)}  ${row.status.label.padRight(14)}  '
      'pass=$rate  ${row.notes}',
    ),
  );
}

String _renderReport(List<_ProviderProbeRow> rows, {required bool live}) {
  final now = DateTime.now().toUtc().toIso8601String();
  final buffer = StringBuffer()
    ..writeln('# Placeholder probe results (TECHNICAL.md Q1)')
    ..writeln()
    ..writeln('- Generated: `$now`')
    ..writeln('- Mode: `${live ? 'live' : 'dry-run'}`')
    ..writeln('- Style under test: `unit` (`U+2063` + `LF<n>`)')
    ..writeln('- Fixtures: ${probeFixtures.length}')
    ..writeln()
    ..writeln('| Provider | Status | Pass | Fail | Notes |')
    ..writeln('|---|---|---:|---:|---|');

  for (final row in rows) {
    buffer.writeln(
      '| ${row.providerId} | ${row.status.label} | ${row.passed} | '
      '${row.failed} | ${row.notes} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Fixture inventory')
    ..writeln()
    ..writeln('| # | Source | Tokens after protect |')
    ..writeln('|---:|---|---:|');

  for (var i = 0; i < probeFixtures.length; i++) {
    final protected = TokenProtector.protect(probeFixtures[i]);
    buffer.writeln(
      '| $i | `${_escapeMd(probeFixtures[i])}` | ${protected.tokens.length} |',
    );
  }

  final anyFailures = rows.any((r) => r.failures.isNotEmpty);
  if (anyFailures) {
    buffer
      ..writeln()
      ..writeln('## Failures')
      ..writeln();
    for (final row in rows) {
      if (row.failures.isEmpty) continue;
      buffer.writeln('### ${row.providerId}');
      buffer.writeln();
      for (final failure in row.failures) {
        buffer.writeln(
          '- `#${failure.index}` `${_escapeMd(failure.source)}` — '
          '${_escapeMd(failure.reason)}'
          '${failure.translatedSample == null ? '' : ' ← `${_escapeMd(failure.translatedSample!)}`'}',
        );
      }
      buffer.writeln();
    }
  }

  buffer
    ..writeln()
    ..writeln('## Next steps (not done by this skeleton)')
    ..writeln()
    ..writeln(
      '1. Paste the summary table into `docs/TECHNICAL.md` Q1 after a live run.',
    )
    ..writeln(
      '2. For failing engines, implement `placeholderStyle` alternatives '
      '(DeepL xml / Google html / Papago exclude) — Phase 8 plan §2.3.',
    )
    ..writeln(
      '3. Re-run `--live` and confirm restore() pass rate before enabling '
      'that engine in production defaults.',
    );

  return SensitiveFilter.scrub(buffer.toString());
}

String _env(String name) => Platform.environment[name]?.trim() ?? '';

String _clip(String value, [int max = 80]) {
  final single = value.replaceAll('\n', r'\n');
  if (single.length <= max) return single;
  return '${single.substring(0, max)}…';
}

String _escapeMd(String value) =>
    value.replaceAll('|', r'\|').replaceAll('\n', r'\n');

class _ProbeTarget {
  const _ProbeTarget({
    required this.id,
    required this.envReady,
    required this.auth,
    required this.build,
  });

  final String id;
  final bool Function() envReady;
  final AuthValues Function() auth;
  final TranslationProvider Function(
    ProviderDefinition definition,
    http.Client client,
  )
  build;
}

enum _ProbeStatus {
  skippedDryRun('skipped (dry-run)'),
  skippedNoKey('skipped (no key)'),
  pass('pass'),
  fail('fail');

  const _ProbeStatus(this.label);
  final String label;
}

class _ProviderProbeRow {
  const _ProviderProbeRow({
    required this.providerId,
    required this.status,
    required this.fixtureCount,
    required this.withTokens,
    required this.passed,
    required this.failed,
    required this.notes,
    required this.failures,
  });

  final String providerId;
  final _ProbeStatus status;
  final int fixtureCount;
  final int withTokens;
  final int passed;
  final int failed;
  final String notes;
  final List<_FixtureFailure> failures;
}

class _FixtureFailure {
  const _FixtureFailure({
    required this.index,
    required this.source,
    required this.reason,
    this.translatedSample,
  });

  final int index;
  final String source;
  final String reason;
  final String? translatedSample;
}
