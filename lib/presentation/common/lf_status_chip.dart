import 'package:flutter/material.dart';
import '../../app/theme/theme_extensions.dart';

enum LfStatusType {
  wait,
  running,
  done,
  kept,
  cache,
  invalid,
  fallback,
  confirm,
  empty;

  String get label {
    switch (this) {
      case LfStatusType.wait:
        return '대기';
      case LfStatusType.running:
        return '번역 중';
      case LfStatusType.done:
        return '새 번역';
      case LfStatusType.kept:
        return '기존 번역 유지';
      case LfStatusType.cache:
        return '캐시 재사용';
      case LfStatusType.invalid:
        return '검증 실패';
      case LfStatusType.fallback:
        return '원문 유지';
      case LfStatusType.confirm:
        return '확인 필요';
      case LfStatusType.empty:
        return '빈 문자열 유지';
    }
  }
}

class LfStatusChip extends StatelessWidget {
  const LfStatusChip({super.key, required this.type, this.customLabel});

  final LfStatusType type;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radii = context.r;
    final spacing = context.s;
    final typography = context.t;

    Color fg;
    Color bg;

    switch (type) {
      case LfStatusType.wait:
        fg = colors.statusWaitFg;
        bg = colors.statusWaitBg;
        break;
      case LfStatusType.running:
        fg = colors.statusRunningFg;
        bg = colors.statusRunningBg;
        break;
      case LfStatusType.done:
        fg = colors.statusDoneFg;
        bg = colors.statusDoneBg;
        break;
      case LfStatusType.kept:
        fg = colors.statusKeptFg;
        bg = colors.statusKeptBg;
        break;
      case LfStatusType.cache:
        fg = colors.statusCacheFg;
        bg = colors.statusCacheBg;
        break;
      case LfStatusType.invalid:
        fg = colors.statusInvalidFg;
        bg = colors.statusInvalidBg;
        break;
      case LfStatusType.fallback:
        fg = colors.statusFallbackFg;
        bg = colors.statusFallbackBg;
        break;
      case LfStatusType.confirm:
        fg = colors.statusConfirmFg;
        bg = colors.statusConfirmBg;
        break;
      case LfStatusType.empty:
        fg = colors.statusEmptyFg;
        bg = colors.statusEmptyBg;
        break;
    }

    final labelText = customLabel ?? type.label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.space3,
        vertical: spacing.space1,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: radii.sm),
      child: Text(
        labelText,
        style: typography.chip.copyWith(color: fg, fontWeight: FontWeight.w500),
      ),
    );
  }
}
