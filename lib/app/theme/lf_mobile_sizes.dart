import 'package:flutter/material.dart';

/// Fixed dimensions for the mobile shell — DESIGN.md 6.3 · MOBILE.md 2.
///
/// A separate extension from [LfSizes] rather than more fields on it: every one
/// of these values exists because the phone layout needed a *different* number
/// than the desktop one, and keeping them apart makes that obvious at the call
/// site. `LfSizes` still supplies anything that is genuinely shared.
///
/// Every number here was measured off `resources/LangForge Mobile
/// (standalone).html`, which DESIGN.md 0.4 makes the authority.
@immutable
class LfMobileSizes extends ThemeExtension<LfMobileSizes> {
  const LfMobileSizes({
    required this.header,
    required this.headerPadding,
    required this.appMark,
    required this.headerButton,
    required this.progressBar,
    required this.bottomTabBar,
    required this.tabBadge,
    required this.runBar,
    required this.runButton,
    required this.pauseButton,
    required this.minTapTarget,
    required this.checkbox,
    required this.radio,
    required this.toggleTrackW,
    required this.toggleTrackH,
    required this.toggleKnob,
    required this.selectField,
    required this.authField,
    required this.exportButton,
    required this.sheetHandleW,
    required this.sheetHandleH,
    required this.sheetTopInset,
    required this.sheetActionButton,
    required this.editorBox,
    required this.toastBottom,
    required this.toastIcon,
    required this.toastClose,
    required this.statIcon,
    required this.precheckIcon,
    required this.chipHeight,
    required this.filterHeight,
    required this.langCodeColumn,
  });

  /// Header row with the app mark, title, subtitle and the settings gear.
  final double header;
  final double headerPadding;
  final double appMark;
  final double headerButton;

  /// The hairline progress bar directly under the header.
  final double progressBar;

  final double bottomTabBar;

  /// The 문제 count pill on the bottom tab.
  final double tabBadge;

  /// Run bar, shown only on the 편집 tab.
  final double runBar;
  final double runButton;
  final double pauseButton;

  /// DESIGN.md 6.3 — 44, not the desktop 24.
  final double minTapTarget;

  final double checkbox;
  final double radio;
  final double toggleTrackW;
  final double toggleTrackH;
  final double toggleKnob;

  final double selectField;
  final double authField;
  final double exportButton;

  /// Bottom sheets — MOBILE.md 2.3.
  final double sheetHandleW;
  final double sheetHandleH;

  /// The settings sheet is pinned this far from the top and scrolls inside.
  final double sheetTopInset;
  final double sheetActionButton;

  /// Translation text area in the edit sheet.
  final double editorBox;

  final double toastBottom;
  final double toastIcon;
  final double toastClose;

  final double statIcon;
  final double precheckIcon;

  /// namespace chips and filter chips above the entry list.
  final double chipHeight;
  final double filterHeight;

  /// Fixed-width column holding `en_us` / `ko_kr` beside each line.
  final double langCodeColumn;

  static const standard = LfMobileSizes(
    header: 54,
    headerPadding: 18,
    appMark: 22,
    headerButton: 32,
    progressBar: 3,
    bottomTabBar: 66,
    tabBadge: 20,
    runBar: 64,
    runButton: 44,
    pauseButton: 84,
    minTapTarget: 44,
    checkbox: 19,
    radio: 16,
    toggleTrackW: 40,
    toggleTrackH: 23,
    toggleKnob: 19,
    selectField: 48,
    authField: 44,
    exportButton: 50,
    sheetHandleW: 38,
    sheetHandleH: 4,
    sheetTopInset: 96,
    sheetActionButton: 44,
    editorBox: 84,
    toastBottom: 104,
    toastIcon: 22,
    toastClose: 24,
    statIcon: 22,
    precheckIcon: 19,
    chipHeight: 30,
    filterHeight: 28,
    langCodeColumn: 34,
  );

  @override
  LfMobileSizes copyWith({
    double? header,
    double? headerPadding,
    double? appMark,
    double? headerButton,
    double? progressBar,
    double? bottomTabBar,
    double? tabBadge,
    double? runBar,
    double? runButton,
    double? pauseButton,
    double? minTapTarget,
    double? checkbox,
    double? radio,
    double? toggleTrackW,
    double? toggleTrackH,
    double? toggleKnob,
    double? selectField,
    double? authField,
    double? exportButton,
    double? sheetHandleW,
    double? sheetHandleH,
    double? sheetTopInset,
    double? sheetActionButton,
    double? editorBox,
    double? toastBottom,
    double? toastIcon,
    double? toastClose,
    double? statIcon,
    double? precheckIcon,
    double? chipHeight,
    double? filterHeight,
    double? langCodeColumn,
  }) {
    return LfMobileSizes(
      header: header ?? this.header,
      headerPadding: headerPadding ?? this.headerPadding,
      appMark: appMark ?? this.appMark,
      headerButton: headerButton ?? this.headerButton,
      progressBar: progressBar ?? this.progressBar,
      bottomTabBar: bottomTabBar ?? this.bottomTabBar,
      tabBadge: tabBadge ?? this.tabBadge,
      runBar: runBar ?? this.runBar,
      runButton: runButton ?? this.runButton,
      pauseButton: pauseButton ?? this.pauseButton,
      minTapTarget: minTapTarget ?? this.minTapTarget,
      checkbox: checkbox ?? this.checkbox,
      radio: radio ?? this.radio,
      toggleTrackW: toggleTrackW ?? this.toggleTrackW,
      toggleTrackH: toggleTrackH ?? this.toggleTrackH,
      toggleKnob: toggleKnob ?? this.toggleKnob,
      selectField: selectField ?? this.selectField,
      authField: authField ?? this.authField,
      exportButton: exportButton ?? this.exportButton,
      sheetHandleW: sheetHandleW ?? this.sheetHandleW,
      sheetHandleH: sheetHandleH ?? this.sheetHandleH,
      sheetTopInset: sheetTopInset ?? this.sheetTopInset,
      sheetActionButton: sheetActionButton ?? this.sheetActionButton,
      editorBox: editorBox ?? this.editorBox,
      toastBottom: toastBottom ?? this.toastBottom,
      toastIcon: toastIcon ?? this.toastIcon,
      toastClose: toastClose ?? this.toastClose,
      statIcon: statIcon ?? this.statIcon,
      precheckIcon: precheckIcon ?? this.precheckIcon,
      chipHeight: chipHeight ?? this.chipHeight,
      filterHeight: filterHeight ?? this.filterHeight,
      langCodeColumn: langCodeColumn ?? this.langCodeColumn,
    );
  }

  @override
  LfMobileSizes lerp(ThemeExtension<LfMobileSizes>? other, double t) {
    if (other is! LfMobileSizes) return this;
    double at(double a, double b) => a + (b - a) * t;
    return LfMobileSizes(
      header: at(header, other.header),
      headerPadding: at(headerPadding, other.headerPadding),
      appMark: at(appMark, other.appMark),
      headerButton: at(headerButton, other.headerButton),
      progressBar: at(progressBar, other.progressBar),
      bottomTabBar: at(bottomTabBar, other.bottomTabBar),
      tabBadge: at(tabBadge, other.tabBadge),
      runBar: at(runBar, other.runBar),
      runButton: at(runButton, other.runButton),
      pauseButton: at(pauseButton, other.pauseButton),
      minTapTarget: at(minTapTarget, other.minTapTarget),
      checkbox: at(checkbox, other.checkbox),
      radio: at(radio, other.radio),
      toggleTrackW: at(toggleTrackW, other.toggleTrackW),
      toggleTrackH: at(toggleTrackH, other.toggleTrackH),
      toggleKnob: at(toggleKnob, other.toggleKnob),
      selectField: at(selectField, other.selectField),
      authField: at(authField, other.authField),
      exportButton: at(exportButton, other.exportButton),
      sheetHandleW: at(sheetHandleW, other.sheetHandleW),
      sheetHandleH: at(sheetHandleH, other.sheetHandleH),
      sheetTopInset: at(sheetTopInset, other.sheetTopInset),
      sheetActionButton: at(sheetActionButton, other.sheetActionButton),
      editorBox: at(editorBox, other.editorBox),
      toastBottom: at(toastBottom, other.toastBottom),
      toastIcon: at(toastIcon, other.toastIcon),
      toastClose: at(toastClose, other.toastClose),
      statIcon: at(statIcon, other.statIcon),
      precheckIcon: at(precheckIcon, other.precheckIcon),
      chipHeight: at(chipHeight, other.chipHeight),
      filterHeight: at(filterHeight, other.filterHeight),
      langCodeColumn: at(langCodeColumn, other.langCodeColumn),
    );
  }
}
