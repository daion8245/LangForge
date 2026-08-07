import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';
import '../../domain/policy/export_gate.dart';
import '../../infrastructure/export/pack_meta_builder.dart';

enum ExportFormatOption {
  zipPack,
  folderPack,
  pathJson,
  namespaceJson,
  perModPacks;

  String labelFor(String outputFileName) => switch (this) {
    ExportFormatOption.zipPack => '통합 ZIP 리소스팩',
    ExportFormatOption.folderPack => '폴더형 리소스팩',
    ExportFormatOption.pathJson =>
      '전체 경로 보존 JSON (assets/{ns}/lang/$outputFileName)',
    ExportFormatOption.namespaceJson =>
      'namespace별 개별 JSON ({ns}/$outputFileName)',
    ExportFormatOption.perModPacks => '모드별 개별 리소스팩 ZIP',
  };
}

class ExportModalView extends StatefulWidget {
  const ExportModalView({
    super.key,
    required this.namespaces,
    required this.entries,
    required this.isTranslating,
    this.hasUnresolvedConflict = false,
    this.allowSkipChecks = false,
    this.outputFileName = 'ko_kr.json',
    this.targetLangCode = 'ko_kr',
    this.onOpenConflicts,
    required this.mcVersionsJsonStr,
    required this.onExportConfirmed,
  });

  final List<NamespaceUnit> namespaces;
  final List<TranslationEntry> entries;
  final bool isTranslating;

  /// Unresolved conflicts block export outright (AC-9.2).
  final bool hasUnresolvedConflict;

  /// When false, the policy override checkboxes stay off and disabled (E3).
  final bool allowSkipChecks;

  final String outputFileName;
  final String targetLangCode;
  final VoidCallback? onOpenConflicts;

  final String mcVersionsJsonStr;
  final void Function(
    ExportFormatOption format,
    String mcVersion,
    int packFormat,
    ExportPolicyOptions options,
  )
  onExportConfirmed;

  @override
  State<ExportModalView> createState() => _ExportModalViewState();
}

class _ExportModalViewState extends State<ExportModalView> {
  ExportFormatOption _selectedFormat = ExportFormatOption.zipPack;
  String _selectedMcVersion = '1.20.1';
  bool _allowPendingEntries = true;
  bool _allowValidationFailed = false;

  final List<String> _mcVersions = [
    '1.21.4',
    '1.21.3',
    '1.21.2',
    '1.21.1',
    '1.21',
    '1.20.6',
    '1.20.4',
    '1.20.2',
    '1.20.1',
    '1.19.4',
    '1.19.2',
    '1.18.2',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    final allowPending = widget.allowSkipChecks ? _allowPendingEntries : true;
    final allowFailed = widget.allowSkipChecks ? _allowValidationFailed : false;

    final policyOptions = ExportPolicyOptions(
      allowPendingEntries: allowPending,
      allowValidationFailed: allowFailed,
    );

    final verdict = ExportGate.evaluate(
      namespaces: widget.namespaces,
      entries: widget.entries,
      isTranslating: widget.isTranslating,
      hasUnresolvedConflict: widget.hasUnresolvedConflict,
      options: policyOptions,
    );
    final isAllowed = verdict is Allowed;

    final packFormat = PackMetaBuilder.getPackFormat(
      widget.mcVersionsJsonStr,
      _selectedMcVersion,
    );

    final waitCount = widget.entries
        .where((e) => e.status == EntryStatus.wait)
        .length;
    final invalidCount = widget.entries
        .where((e) => e.status == EntryStatus.invalid)
        .length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(spacing.space8),
      child: Container(
        constraints: BoxConstraints(maxWidth: context.d.modalLg),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: radii.r4xl,
          border: Border.all(
            color: colors.borderPanel,
            width: context.d.borderThin,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: context.d.modalHeader,
              padding: EdgeInsets.symmetric(horizontal: spacing.space8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderDefault,
                    width: context.d.borderThin,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.package, size: context.d.iconMd),
                  SizedBox(width: spacing.space4),
                  Text('출력 전 검사', style: typography.title),
                  const Spacer(),
                  IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(LucideIcons.x, size: context.d.iconMd),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatColumn('대기', '$waitCount', colors.textMuted),
                        _buildStatColumn(
                          '검증 실패',
                          '$invalidCount',
                          colors.dangerText,
                        ),
                        _buildStatColumn(
                          '대상 언어',
                          widget.targetLangCode,
                          colors.accent,
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.space6),
                    Text('Minecraft 버전', style: typography.bodySm),
                    SizedBox(height: spacing.space3),
                    DropdownButton<String>(
                      value: _selectedMcVersion,
                      isExpanded: true,
                      items: _mcVersions
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedMcVersion = v);
                      },
                    ),
                    Text(
                      'pack_format: $packFormat',
                      style: typography.caption.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    SizedBox(height: spacing.space6),
                    Text('출력 형식', style: typography.bodySm),
                    SizedBox(height: spacing.space3),
                    RadioGroup<ExportFormatOption>(
                      groupValue: _selectedFormat,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedFormat = val);
                        }
                      },
                      child: Column(
                        children: [
                          for (final opt in ExportFormatOption.values)
                            RadioListTile<ExportFormatOption>(
                              dense: true,
                              value: opt,
                              title: Text(
                                opt.labelFor(widget.outputFileName),
                                style: typography.bodySm.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.space6),
                    CheckboxListTile(
                      dense: true,
                      value: allowPending,
                      title: Text(
                        '대기 항목 원문 유지 후 출력 허용',
                        style: typography.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      onChanged: widget.allowSkipChecks
                          ? (val) => setState(
                              () => _allowPendingEntries = val == true,
                            )
                          : null,
                    ),
                    CheckboxListTile(
                      dense: true,
                      value: allowFailed,
                      title: Text(
                        '검증 실패 항목 포함 출력 허용 (권장하지 않음)',
                        style: typography.bodySm.copyWith(
                          color: colors.dangerText,
                        ),
                      ),
                      onChanged: widget.allowSkipChecks
                          ? (val) => setState(
                              () => _allowValidationFailed = val == true,
                            )
                          : null,
                    ),
                    if (!widget.allowSkipChecks)
                      Padding(
                        padding: EdgeInsets.only(top: spacing.space2),
                        child: Text(
                          '검사 우회는 환경설정에서 "출력 전 검사 건너뛰기 허용"을 켠 뒤에만 사용할 수 있습니다.',
                          style: typography.caption.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    if (!isAllowed && verdict is Blocked) ...[
                      SizedBox(height: spacing.space6),
                      Container(
                        padding: EdgeInsets.all(spacing.space6),
                        decoration: BoxDecoration(
                          color: colors.dangerSurface,
                          borderRadius: radii.r2xl,
                          border: Border.all(
                            color: colors.dangerBorder,
                            width: context.d.borderThin,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '내보내기 차단 원인: ${verdict.reasons.map((r) => r.name).join(', ')}',
                              style: typography.caption.copyWith(
                                color: colors.dangerText,
                              ),
                            ),
                            if (widget.hasUnresolvedConflict &&
                                widget.onOpenConflicts != null) ...[
                              SizedBox(height: spacing.space4),
                              TextButton(
                                onPressed: widget.onOpenConflicts,
                                child: const Text('충돌 해결 열기'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              height: context.d.modalFooter,
              padding: EdgeInsets.symmetric(horizontal: spacing.space8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.borderDefault,
                    width: context.d.borderThin,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  SizedBox(width: spacing.space4),
                  ElevatedButton(
                    onPressed: !isAllowed
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onExportConfirmed(
                              _selectedFormat,
                              _selectedMcVersion,
                              packFormat,
                              policyOptions,
                            );
                          },
                    child: Text(isAllowed ? '내보내기 실행' : '내보내기 차단됨'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.t.caption.copyWith(color: context.c.textMuted),
          ),
          Text(value, style: context.t.body.copyWith(color: color)),
        ],
      ),
    );
  }
}
