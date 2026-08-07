import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../infrastructure/db/row_mappers.dart';
import '../../../infrastructure/export/pack_meta_builder.dart';
import '../../../domain/policy/merge_policy.dart';
import '../../../domain/validation/json_rebuilder.dart';
import '../../../infrastructure/db/app_database.dart';

class OutputPreviewView extends StatelessWidget {
  const OutputPreviewView({
    super.key,
    required this.namespaces,
    required this.entries,
    this.packFormat = 15,
    this.includesPackIcon = true,
    this.outputFileName = 'ko_kr.json',
  });

  final List<Namespace> namespaces;
  final List<Entry> entries;
  final int packFormat;

  /// Whether the exported pack will carry a `pack.png`.
  final bool includesPackIcon;

  /// Comes from the target language profile (TECHNICAL.md 4.6).
  final String outputFileName;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    final activeNamespaces = namespaces.where((ns) => !ns.excluded).toList();
    final sampleNs = activeNamespaces.firstOrNull;

    final sampleEntries = sampleNs != null
        ? entries.where((e) => e.namespaceId == sampleNs.id).take(5).toList()
        : <Entry>[];

    final sampleMap = <String, String>{};
    final sampleOrder = <String>[];
    for (final e in sampleEntries) {
      sampleOrder.add(e.key);
      sampleMap[e.key] = MergePolicy.resolveFinal(e.toDomain());
    }

    final jsonSample = JsonRebuilder.rebuild(
      entries: sampleMap,
      keyOrder: sampleOrder,
    );
    final packMetaSample = PackMetaBuilder.buildPackMeta(
      packFormat: packFormat,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '출력 결과물 구조 미리보기',
            style: typography.title.copyWith(color: colors.textPrimary),
          ),
          SizedBox(height: spacing.space4),
          Text(
            '통합 ZIP 리소스팩(KO_Translation_Pack.zip) 생성 시 포함되는 파일과 폴더 구조입니다.',
            style: typography.bodySm.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.space8),

          // File Tree Preview Card
          Container(
            padding: EdgeInsets.all(spacing.space7),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: radii.r2xl,
              border: Border.all(
                color: colors.borderPanel,
                width: context.d.borderThin,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.archive,
                      size: context.d.iconMd,
                      color: colors.accent,
                    ),
                    SizedBox(width: spacing.space4),
                    Text(
                      'KO_Translation_Pack.zip',
                      style: typography.codeBody.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.space4),
                _buildTreeRow(context, 'pack.mcmeta', isFile: true, indent: 1),
                if (includesPackIcon)
                  _buildTreeRow(context, 'pack.png', isFile: true, indent: 1),
                _buildTreeRow(context, 'assets/', isFile: false, indent: 1),
                ...activeNamespaces.map(
                  (ns) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTreeRow(
                        context,
                        '${ns.name}/',
                        isFile: false,
                        indent: 2,
                      ),
                      _buildTreeRow(context, 'lang/', isFile: false, indent: 3),
                      _buildTreeRow(
                        context,
                        outputFileName,
                        isFile: true,
                        indent: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.space10),

          // pack.mcmeta Code Preview
          Text(
            'pack.mcmeta 미리보기',
            style: typography.overline.copyWith(color: colors.textFaint),
          ),
          SizedBox(height: spacing.space3),
          _buildCodeBlock(context, packMetaSample),

          SizedBox(height: spacing.space8),

          // ko_kr.json Code Preview
          Text(
            '$outputFileName 미리보기 (${sampleNs?.name ?? 'Sample'})',
            style: typography.overline.copyWith(color: colors.textFaint),
          ),
          SizedBox(height: spacing.space3),
          _buildCodeBlock(context, jsonSample),
        ],
      ),
    );
  }

  Widget _buildTreeRow(
    BuildContext context,
    String name, {
    required bool isFile,
    required int indent,
  }) {
    final colors = context.c;
    return Padding(
      padding: EdgeInsets.only(
        left: indent * context.d.iconLg,
        top: context.s.space1,
        bottom: context.s.space1,
      ),
      child: Row(
        children: [
          Icon(
            isFile ? LucideIcons.fileText : LucideIcons.folder,
            size: context.d.iconSm,
            color: isFile ? colors.textSecondary : colors.accent,
          ),
          SizedBox(width: context.s.space5),
          Text(
            name,
            style: context.t.codeSm.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(BuildContext context, String code) {
    final colors = context.c;
    final radii = context.r;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.s.space7),
      decoration: BoxDecoration(
        color: colors.bgRaised,
        borderRadius: radii.r2xl,
        border: Border.all(
          color: colors.borderControl,
          width: context.d.borderThin,
        ),
      ),
      child: SelectableText(
        code,
        style: context.t.codeBody.copyWith(color: colors.textPrimary),
      ),
    );
  }
}
