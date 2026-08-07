import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../domain/model/entry_status.dart';
import '../../../domain/protection/multiset.dart';

/// Foreground/background pair for a status, straight off the mockup's STATUS
/// table. Kept next to the mobile chip rather than in the shared widget because
/// the mobile chip is a different size and the desktop one already has its own.
({Color fg, Color bg}) mobileStatusColors(BuildContext context, EntryStatus s) {
  final c = context.c;
  return switch (s) {
    EntryStatus.wait => (fg: c.statusWaitFg, bg: c.statusWaitBg),
    EntryStatus.running => (fg: c.statusRunningFg, bg: c.statusRunningBg),
    EntryStatus.done => (fg: c.statusDoneFg, bg: c.statusDoneBg),
    EntryStatus.kept => (fg: c.statusKeptFg, bg: c.statusKeptBg),
    EntryStatus.cache => (fg: c.statusCacheFg, bg: c.statusCacheBg),
    EntryStatus.invalid => (fg: c.statusInvalidFg, bg: c.statusInvalidBg),
    EntryStatus.fallback => (fg: c.statusFallbackFg, bg: c.statusFallbackBg),
    EntryStatus.confirm => (fg: c.statusConfirmFg, bg: c.statusConfirmBg),
    EntryStatus.empty => (fg: c.statusEmptyFg, bg: c.statusEmptyBg),
  };
}

/// Chip text per status.
///
/// Two labels are shorter than the desktop ones (`기존 번역 유지` → `기존 유지`,
/// `캐시 재사용` → `캐시`): the mockup shortens them so the chip never wraps
/// beside a key on a 390px screen.
String mobileStatusLabel(EntryStatus status) => switch (status) {
  EntryStatus.wait => '대기',
  EntryStatus.running => '번역 중',
  EntryStatus.done => '새 번역',
  EntryStatus.kept => '기존 유지',
  EntryStatus.cache => '캐시',
  EntryStatus.invalid => '검증 실패',
  EntryStatus.fallback => '원문 유지',
  EntryStatus.confirm => '확인 필요',
  EntryStatus.empty => '빈 문자열',
};

/// Status chip — height 19, padding 0/8, radius 6, 10.5px.
class MobileStatusChip extends StatelessWidget {
  const MobileStatusChip({super.key, required this.status, this.label});

  final EntryStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = mobileStatusColors(context, status);
    return Container(
      height: 19,
      padding: EdgeInsets.symmetric(horizontal: context.s.space8 / 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: colors.bg, borderRadius: context.r.md),
      child: Text(
        label ?? mobileStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.t.chip.copyWith(color: colors.fg),
      ),
    );
  }
}

/// Protected-token chip — DESIGN.md 7.3.
///
/// Shows the source count even when it is zero: a token the translation
/// invented is exactly the case that has to be visible.
class MobileVarChip extends StatelessWidget {
  const MobileVarChip({super.key, required this.info});

  final TokenChipInfo info;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final matched = info.isMatch;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.s.space3,
        vertical: context.s.space1,
      ),
      decoration: BoxDecoration(
        color: matched ? colors.statusDoneBg : colors.statusInvalidBg,
        borderRadius: context.r.sm,
      ),
      child: Text(
        '${info.token} ×${info.sourceCount}',
        style: context.t.codeSm.copyWith(
          fontSize: 10,
          color: matched ? colors.accent : colors.danger,
        ),
      ),
    );
  }
}

/// namespace selector chip above the entry list — height 30, radius 9.
class MobileNamespaceChip extends StatelessWidget {
  const MobileNamespaceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.r2xl,
        child: Container(
          height: context.m.chipHeight,
          padding: EdgeInsets.symmetric(horizontal: context.s.space7 - 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colors.accent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: context.r.r2xl,
            border: Border.all(
              color: selected ? colors.borderAccent : colors.borderPanel,
              width: context.d.borderThin,
            ),
          ),
          child: Text(
            label,
            style: context.t.codeBody.copyWith(
              color: selected ? colors.accent : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Status filter chip — height 28, radius 8.
class MobileFilterChip extends StatelessWidget {
  const MobileFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.r.xl,
        child: Container(
          height: context.m.filterHeight,
          padding: EdgeInsets.symmetric(horizontal: context.s.space7 - 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.bgSelected : Colors.transparent,
            borderRadius: context.r.xl,
            border: Border.all(
              color: selected ? colors.borderStrong : colors.borderDefault,
              width: context.d.borderThin,
            ),
          ),
          child: Text(
            label,
            style: context.t.label.copyWith(
              color: selected ? colors.textStrong : colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
