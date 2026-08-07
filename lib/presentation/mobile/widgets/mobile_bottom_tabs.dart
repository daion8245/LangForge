import 'package:flutter/material.dart';

import '../../../app/theme/theme_extensions.dart';
import '../../../application/mobile/mobile_ui_controller.dart';

/// The four bottom tabs of DESIGN.md 6.3 — 파일 · 편집 · 문제 · 출력.
///
/// 문제 carries a count badge; the other three keep the same-height empty slot
/// so the labels stay on one baseline whether or not a badge is showing.
class MobileBottomTabs extends StatelessWidget {
  const MobileBottomTabs({
    super.key,
    required this.current,
    required this.issueCount,
    required this.onSelect,
  });

  final MobileTab current;
  final int issueCount;
  final ValueChanged<MobileTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      height: context.m.bottomTabBar,
      decoration: BoxDecoration(
        color: colors.bgBar,
        border: Border(
          top: BorderSide(
            color: colors.borderDefault,
            width: context.d.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          for (final tab in MobileTab.values)
            Expanded(
              child: _Tab(
                tab: tab,
                selected: tab == current,
                badge: tab == MobileTab.issues ? issueCount : 0,
                onTap: () => onSelect(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.tab,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final MobileTab tab;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final sizes = context.m;
    final showBadge = badge > 0;

    // The badge and the label are two nodes visually but one thing to a reader,
    // so the tab speaks for itself and its children stay silent — otherwise
    // 문제 announces as "3" then "문제", which says nothing about what the 3 is.
    return Semantics(
      selected: selected,
      button: true,
      container: true,
      excludeSemantics: true,
      label: showBadge ? '${tab.label} $badge건' : tab.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(minWidth: sizes.tabBadge),
              height: sizes.tabBadge,
              padding: EdgeInsets.symmetric(horizontal: context.s.space3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: showBadge ? colors.statusInvalidBg : Colors.transparent,
                borderRadius: context.r.full,
              ),
              child: showBadge
                  ? Text(
                      '$badge',
                      style: context.t.codeSm.copyWith(
                        fontSize: 10.5,
                        color: colors.danger,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: context.s.space1),
            Text(
              tab.label,
              style: context.t.micro.copyWith(
                color: selected ? colors.accent : colors.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
