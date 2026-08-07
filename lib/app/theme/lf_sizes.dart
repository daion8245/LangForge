import 'package:flutter/material.dart';

/// Fixed dimensions from DESIGN.md 5.5.
///
/// Every value here is already stated somewhere in DESIGN.md — 6.1 for the
/// layout, 6.2 for the breakpoints, 7 for the components. Collecting them into
/// one extension is what lets AGENTS.md 2.5 hold: no widget spells a size out
/// as a literal, so a change to the design lands in exactly one place.
@immutable
class LfSizes extends ThemeExtension<LfSizes> {
  const LfSizes({
    required this.topBar,
    required this.statusBar,
    required this.explorerPanel,
    required this.settingsPanel,
    required this.editorMin,
    required this.tabBar,
    required this.filterBar,
    required this.treeRowFile,
    required this.treeRowNamespace,
    required this.buttonPrimary,
    required this.buttonSecondary,
    required this.buttonTertiary,
    required this.buttonDanger,
    required this.checkbox,
    required this.statusDot,
    required this.iconSm,
    required this.iconMd,
    required this.iconLg,
    required this.iconXl,
    required this.searchField,
    required this.langLabel,
    required this.modalSm,
    required this.modalMd,
    required this.modalLg,
    required this.modalXl,
    required this.recentList,
    required this.borderThin,
    required this.borderThick,
    required this.minTapTarget,
    required this.modalHeader,
    required this.modalFooter,
    required this.progressBarWidth,
    required this.progressBarHeight,
    required this.emptyStateIcon,
    required this.breakpointWide,
    required this.breakpointNarrow,
    required this.breakpointMobile,
  });

  /// Layout — DESIGN.md 6.1.
  final double topBar;
  final double statusBar;
  final double explorerPanel;
  final double settingsPanel;
  final double editorMin;

  /// Editor chrome — DESIGN.md 7.9 · 7.10.
  final double tabBar;
  final double filterBar;
  final double treeRowFile;
  final double treeRowNamespace;

  /// Control heights — DESIGN.md 7.1.
  final double buttonPrimary;
  final double buttonSecondary;
  final double buttonTertiary;
  final double buttonDanger;

  final double checkbox;
  final double statusDot;

  /// Icon sizes — DESIGN.md 7.
  final double iconSm;
  final double iconMd;
  final double iconLg;
  final double iconXl;

  final double searchField;
  final double langLabel;

  /// Maximum widths for surfaces that float over the editor.
  final double modalSm;
  final double modalMd;
  final double modalLg;
  final double modalXl;
  final double recentList;

  /// Border widths — DESIGN.md 5.4.
  final double borderThin;
  final double borderThick;

  /// Smallest interactive area, regardless of the visual size (DESIGN.md 14).
  final double minTapTarget;

  /// Measured from the implementation rather than the mockup — DESIGN.md 5.5.
  final double modalHeader;
  final double modalFooter;
  final double progressBarWidth;
  final double progressBarHeight;
  final double emptyStateIcon;

  /// Responsive steps — DESIGN.md 6.2.
  final double breakpointWide;
  final double breakpointNarrow;
  final double breakpointMobile;

  static const standard = LfSizes(
    topBar: 46,
    statusBar: 30,
    explorerPanel: 300,
    settingsPanel: 336,
    editorMin: 664,
    tabBar: 34,
    filterBar: 36,
    treeRowFile: 28,
    treeRowNamespace: 26,
    buttonPrimary: 38,
    buttonSecondary: 28,
    buttonTertiary: 25,
    buttonDanger: 32,
    checkbox: 15,
    statusDot: 6,
    iconSm: 14,
    iconMd: 16,
    iconLg: 18,
    iconXl: 40,
    searchField: 200,
    langLabel: 48,
    modalSm: 420,
    modalMd: 520,
    modalLg: 560,
    modalXl: 680,
    recentList: 320,
    borderThin: 1,
    borderThick: 2,
    minTapTarget: 24,
    modalHeader: 52,
    modalFooter: 60,
    progressBarWidth: 120,
    progressBarHeight: 4,
    emptyStateIcon: 48,
    breakpointWide: 1300,
    breakpointNarrow: 1024,
    breakpointMobile: 768,
  );

  @override
  LfSizes copyWith({
    double? topBar,
    double? statusBar,
    double? explorerPanel,
    double? settingsPanel,
    double? editorMin,
    double? tabBar,
    double? filterBar,
    double? treeRowFile,
    double? treeRowNamespace,
    double? buttonPrimary,
    double? buttonSecondary,
    double? buttonTertiary,
    double? buttonDanger,
    double? checkbox,
    double? statusDot,
    double? iconSm,
    double? iconMd,
    double? iconLg,
    double? iconXl,
    double? searchField,
    double? langLabel,
    double? modalSm,
    double? modalMd,
    double? modalLg,
    double? modalXl,
    double? recentList,
    double? borderThin,
    double? borderThick,
    double? minTapTarget,
    double? modalHeader,
    double? modalFooter,
    double? progressBarWidth,
    double? progressBarHeight,
    double? emptyStateIcon,
    double? breakpointWide,
    double? breakpointNarrow,
    double? breakpointMobile,
  }) {
    return LfSizes(
      topBar: topBar ?? this.topBar,
      statusBar: statusBar ?? this.statusBar,
      explorerPanel: explorerPanel ?? this.explorerPanel,
      settingsPanel: settingsPanel ?? this.settingsPanel,
      editorMin: editorMin ?? this.editorMin,
      tabBar: tabBar ?? this.tabBar,
      filterBar: filterBar ?? this.filterBar,
      treeRowFile: treeRowFile ?? this.treeRowFile,
      treeRowNamespace: treeRowNamespace ?? this.treeRowNamespace,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,
      buttonTertiary: buttonTertiary ?? this.buttonTertiary,
      buttonDanger: buttonDanger ?? this.buttonDanger,
      checkbox: checkbox ?? this.checkbox,
      statusDot: statusDot ?? this.statusDot,
      iconSm: iconSm ?? this.iconSm,
      iconMd: iconMd ?? this.iconMd,
      iconLg: iconLg ?? this.iconLg,
      iconXl: iconXl ?? this.iconXl,
      searchField: searchField ?? this.searchField,
      langLabel: langLabel ?? this.langLabel,
      modalSm: modalSm ?? this.modalSm,
      modalMd: modalMd ?? this.modalMd,
      modalLg: modalLg ?? this.modalLg,
      modalXl: modalXl ?? this.modalXl,
      recentList: recentList ?? this.recentList,
      borderThin: borderThin ?? this.borderThin,
      borderThick: borderThick ?? this.borderThick,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      modalHeader: modalHeader ?? this.modalHeader,
      modalFooter: modalFooter ?? this.modalFooter,
      progressBarWidth: progressBarWidth ?? this.progressBarWidth,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      emptyStateIcon: emptyStateIcon ?? this.emptyStateIcon,
      breakpointWide: breakpointWide ?? this.breakpointWide,
      breakpointNarrow: breakpointNarrow ?? this.breakpointNarrow,
      breakpointMobile: breakpointMobile ?? this.breakpointMobile,
    );
  }

  @override
  LfSizes lerp(ThemeExtension<LfSizes>? other, double t) {
    if (other is! LfSizes) return this;
    double at(double a, double b) => a + (b - a) * t;
    return LfSizes(
      topBar: at(topBar, other.topBar),
      statusBar: at(statusBar, other.statusBar),
      explorerPanel: at(explorerPanel, other.explorerPanel),
      settingsPanel: at(settingsPanel, other.settingsPanel),
      editorMin: at(editorMin, other.editorMin),
      tabBar: at(tabBar, other.tabBar),
      filterBar: at(filterBar, other.filterBar),
      treeRowFile: at(treeRowFile, other.treeRowFile),
      treeRowNamespace: at(treeRowNamespace, other.treeRowNamespace),
      buttonPrimary: at(buttonPrimary, other.buttonPrimary),
      buttonSecondary: at(buttonSecondary, other.buttonSecondary),
      buttonTertiary: at(buttonTertiary, other.buttonTertiary),
      buttonDanger: at(buttonDanger, other.buttonDanger),
      checkbox: at(checkbox, other.checkbox),
      statusDot: at(statusDot, other.statusDot),
      iconSm: at(iconSm, other.iconSm),
      iconMd: at(iconMd, other.iconMd),
      iconLg: at(iconLg, other.iconLg),
      iconXl: at(iconXl, other.iconXl),
      searchField: at(searchField, other.searchField),
      langLabel: at(langLabel, other.langLabel),
      modalSm: at(modalSm, other.modalSm),
      modalMd: at(modalMd, other.modalMd),
      modalLg: at(modalLg, other.modalLg),
      modalXl: at(modalXl, other.modalXl),
      recentList: at(recentList, other.recentList),
      borderThin: at(borderThin, other.borderThin),
      borderThick: at(borderThick, other.borderThick),
      minTapTarget: at(minTapTarget, other.minTapTarget),
      modalHeader: at(modalHeader, other.modalHeader),
      modalFooter: at(modalFooter, other.modalFooter),
      progressBarWidth: at(progressBarWidth, other.progressBarWidth),
      progressBarHeight: at(progressBarHeight, other.progressBarHeight),
      emptyStateIcon: at(emptyStateIcon, other.emptyStateIcon),
      breakpointWide: at(breakpointWide, other.breakpointWide),
      breakpointNarrow: at(breakpointNarrow, other.breakpointNarrow),
      breakpointMobile: at(breakpointMobile, other.breakpointMobile),
    );
  }
}
