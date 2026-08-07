import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../../app/theme/theme_extensions.dart';
import '../../infrastructure/logging/file_logger.dart';
import '../../infrastructure/logging/log_buffer.dart';
import '../common/lf_button.dart';

/// ROADMAP 10.7 — the log without leaving the app.
///
/// Shows what [LogBuffer] kept in memory for this session. The rotating files
/// under `%APPDATA%\LangForge\logs` remain the full record, so the header says
/// where they are.
class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  Level _minLevel = Level.INFO;

  static const _levels = [Level.FINE, Level.INFO, Level.WARNING, Level.SEVERE];

  List<LogLine> get _visible => LogBuffer.instance.lines
      .where((line) => line.level >= _minLevel)
      .toList()
      .reversed
      .toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final spacing = context.s;

    return Scaffold(
      backgroundColor: colors.bgBase,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.d.topBar),
        child: Material(
          color: colors.bgBar,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.space7),
              child: Row(
                children: [
                  Text('로그', style: context.t.title),
                  SizedBox(width: spacing.space8),
                  DropdownButton<Level>(
                    value: _minLevel,
                    underline: const SizedBox.shrink(),
                    dropdownColor: colors.bgSurface,
                    style: context.t.body,
                    items: [
                      for (final level in _levels)
                        DropdownMenuItem(
                          value: level,
                          child: Text('${level.name} 이상'),
                        ),
                    ],
                    onChanged: (level) {
                      if (level == null) return;
                      setState(() => _minLevel = level);
                    },
                  ),
                  const Spacer(),
                  LfButton(
                    onPressed: _copyAll,
                    label: '전체 복사',
                    style: LfButtonStyle.tertiary,
                  ),
                  SizedBox(width: spacing.space5),
                  LfButton(
                    onPressed: () {
                      LogBuffer.instance.clear();
                      setState(() {});
                    },
                    label: '지우기',
                    style: LfButtonStyle.tertiary,
                  ),
                  SizedBox(width: spacing.space5),
                  LfButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    label: '닫기',
                    style: LfButtonStyle.tertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(spacing.space7),
            child: Text(
              '로그 파일 위치: '
              '${FileLogger.instance.logDirectory?.path ?? '(아직 없음)'}',
              style: context.t.caption.copyWith(color: colors.textMuted),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: LogBuffer.instance,
              builder: (context, _) {
                final lines = _visible;
                if (lines.isEmpty) {
                  return Center(
                    child: Text(
                      '표시할 로그가 없습니다.',
                      style: context.t.body.copyWith(color: colors.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: spacing.space7),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing.space2),
                      child: SelectableText(
                        line.formatted,
                        style: context.t.codeBody.copyWith(
                          color: _levelColor(context, line.level),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(BuildContext context, Level level) {
    final colors = context.c;
    if (level >= Level.SEVERE) return colors.danger;
    if (level >= Level.WARNING) return colors.warning;
    if (level <= Level.FINE) return colors.textMuted;
    return colors.textPrimary;
  }

  Future<void> _copyAll() async {
    final text = _visible.reversed.map((line) => line.formatted).join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('로그를 복사했습니다.')));
  }
}
