import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme/theme_extensions.dart';
import '../../domain/policy/export_gate.dart';
import '../../infrastructure/export/pack_meta_builder.dart';

import '../../domain/model/entry_status.dart';
import '../../domain/model/translation_entry.dart';

enum ExportFormatOption {
  zipPack('통합 ZIP 리소스팩 (KO_Translation_Pack.zip)'),
  folderPack('폴더형 리소스팩 (LangForge_Translation_Pack/)'),
  pathJson('전체 경로 보존 JSON (assets/{ns}/lang/ko_kr.json)'),
  namespaceJson('namespace별 개별 JSON ({ns}/ko_kr.json)');

  final String label;
  const ExportFormatOption(this.label);
}

class ExportModalView extends StatefulWidget {
  const ExportModalView({
    super.key,
    required this.namespaces,
    required this.entries,
    required this.isTranslating,
    required this.mcVersionsJsonStr,
    required this.onExportConfirmed,
  });

  final List<NamespaceUnit> namespaces;
  final List<TranslationEntry> entries;
  final bool isTranslating;
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

    final policyOptions = ExportPolicyOptions(
      allowPendingEntries: _allowPendingEntries,
      allowValidationFailed: _allowValidationFailed,
    );

    // Cast entries & namespaces for ExportGate evaluation
    final verdict = ExportGate.evaluate(
      namespaces: widget.namespaces,
      entries: widget.entries,
      isTranslating: widget.isTranslating,
      options: policyOptions,
    );

    final isAllowed = verdict is Allowed;
    final packFormat = PackMetaBuilder.getPackFormat(
      widget.mcVersionsJsonStr,
      _selectedMcVersion,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(spacing.space8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: radii.r4xl,
          border: Border.all(color: colors.borderPanel, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Container(
              height: 52,
              padding: EdgeInsets.symmetric(horizontal: spacing.space8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.borderDefault, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '리소스팩 및 번역 내보내기',
                    style: typography.body.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: colors.textMuted,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Section
                    Text(
                      '내보내기 집계 요약',
                      style: typography.overline.copyWith(
                        color: colors.textFaint,
                      ),
                    ),
                    SizedBox(height: spacing.space3),
                    Container(
                      padding: EdgeInsets.all(spacing.space6),
                      decoration: BoxDecoration(
                        color: colors.bgRaised,
                        borderRadius: radii.r2xl,
                        border: Border.all(
                          color: colors.borderControl,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            '전체 키',
                            widget.entries.length.toString(),
                            colors.textPrimary,
                          ),
                          _buildStatColumn(
                            '대기',
                            widget.entries
                                .where((e) => e.status == EntryStatus.wait)
                                .length
                                .toString(),
                            colors.textMuted,
                          ),
                          _buildStatColumn(
                            '완료',
                            widget.entries
                                .where((e) => e.status == EntryStatus.done)
                                .length
                                .toString(),
                            colors.statusDoneFg,
                          ),
                          _buildStatColumn(
                            '유지',
                            widget.entries
                                .where((e) => e.status == EntryStatus.kept)
                                .length
                                .toString(),
                            colors.accent,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.space8),

                    // Target MC Version
                    Text(
                      '타겟 Minecraft 버전',
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.space3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.bgRaised,
                        borderRadius: radii.r2xl,
                        border: Border.all(
                          color: colors.borderControl,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMcVersion,
                          isExpanded: true,
                          dropdownColor: colors.bgRaised,
                          items: _mcVersions.map((v) {
                            final fmt = PackMetaBuilder.getPackFormat(
                              widget.mcVersionsJsonStr,
                              v,
                            );
                            return DropdownMenuItem(
                              value: v,
                              child: Text(
                                'Minecraft $v (pack_format: $fmt)',
                                style: typography.bodySm.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMcVersion = val);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.space8),

                    // Format Selection Radio Group
                    Text(
                      '내보내기 형식',
                      style: typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.space3),
                    ...ExportFormatOption.values.map((opt) {
                      // ignore: deprecated_member_use
                      return RadioListTile<ExportFormatOption>(
                        dense: true,
                        value: opt,
                        // ignore: deprecated_member_use
                        groupValue: _selectedFormat,
                        title: Text(
                          opt.label,
                          style: typography.bodySm.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        // ignore: deprecated_member_use
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFormat = val);
                          }
                        },
                      );
                    }),
                    SizedBox(height: spacing.space6),

                    // Policy Checkboxes
                    CheckboxListTile(
                      dense: true,
                      value: _allowPendingEntries,
                      title: Text(
                        '대기 항목 원문 유지 후 출력 허용',
                        style: typography.bodySm.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => _allowPendingEntries = val == true),
                    ),
                    CheckboxListTile(
                      dense: true,
                      value: _allowValidationFailed,
                      title: Text(
                        '검증 실패 항목 포함 출력 허용 (권장하지 않음)',
                        style: typography.bodySm.copyWith(
                          color: colors.dangerText,
                        ),
                      ),
                      onChanged: (val) =>
                          setState(() => _allowValidationFailed = val == true),
                    ),

                    // Blocked Reasons Alert
                    if (!isAllowed && verdict is Blocked) ...[
                      SizedBox(height: spacing.space6),
                      Container(
                        padding: EdgeInsets.all(spacing.space6),
                        decoration: BoxDecoration(
                          color: colors.dangerSurface,
                          borderRadius: radii.r2xl,
                          border: Border.all(
                            color: colors.dangerBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '내보내기 차단 원인: ${verdict.reasons.map((r) => r.name).join(', ')}',
                          style: typography.caption.copyWith(
                            color: colors.dangerText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Modal Footer
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: spacing.space8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.borderDefault, width: 1),
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
    return Column(
      children: [
        Text(value, style: context.t.title.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          style: context.t.caption.copyWith(color: context.c.textMuted),
        ),
      ],
    );
  }
}
