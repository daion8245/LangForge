import 'package:flutter/material.dart';

@immutable
class LfTypography extends ThemeExtension<LfTypography> {
  const LfTypography({
    required this.display,
    required this.title,
    required this.heading,
    required this.body,
    required this.bodySm,
    required this.label,
    required this.caption,
    required this.micro,
    required this.chip,
    required this.overline,
    required this.codeBody,
    required this.codeSm,
  });

  final TextStyle display;
  final TextStyle title;
  final TextStyle heading;
  final TextStyle body;
  final TextStyle bodySm;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle micro;
  final TextStyle chip;
  final TextStyle overline;
  final TextStyle codeBody;
  final TextStyle codeSm;

  static const _sansFamily = 'IBM Plex Sans KR';
  static const _monoFamily = 'JetBrains Mono';

  static const standard = LfTypography(
    display: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    title: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    heading: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w600,
    ),
    body: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 13,
      height: 1.65,
      fontWeight: FontWeight.w400,
    ),
    bodySm: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 12.5,
      height: 1.6,
      fontWeight: FontWeight.w400,
    ),
    label: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 12,
      height: 1.6,
      fontWeight: FontWeight.w400,
    ),
    caption: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 11.5,
      height: 1.7,
      fontWeight: FontWeight.w400,
    ),
    micro: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 11,
      height: 1.7,
      fontWeight: FontWeight.w400,
    ),
    chip: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 10.5,
      height: 1.4,
      fontWeight: FontWeight.w400,
    ),
    overline: TextStyle(
      fontFamily: _sansFamily,
      fontSize: 10.5,
      height: 1.4,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.13 * 10.5,
    ),
    codeBody: TextStyle(
      fontFamily: _monoFamily,
      fontSize: 12.5,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    codeSm: TextStyle(
      fontFamily: _monoFamily,
      fontSize: 11,
      height: 1.4,
      fontWeight: FontWeight.w400,
    ),
  );

  @override
  LfTypography copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? body,
    TextStyle? bodySm,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? micro,
    TextStyle? chip,
    TextStyle? overline,
    TextStyle? codeBody,
    TextStyle? codeSm,
  }) {
    return LfTypography(
      display: display ?? this.display,
      title: title ?? this.title,
      heading: heading ?? this.heading,
      body: body ?? this.body,
      bodySm: bodySm ?? this.bodySm,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      micro: micro ?? this.micro,
      chip: chip ?? this.chip,
      overline: overline ?? this.overline,
      codeBody: codeBody ?? this.codeBody,
      codeSm: codeSm ?? this.codeSm,
    );
  }

  @override
  LfTypography lerp(ThemeExtension<LfTypography>? other, double t) {
    if (other is! LfTypography) return this;
    return LfTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySm: TextStyle.lerp(bodySm, other.bodySm, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      micro: TextStyle.lerp(micro, other.micro, t)!,
      chip: TextStyle.lerp(chip, other.chip, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      codeBody: TextStyle.lerp(codeBody, other.codeBody, t)!,
      codeSm: TextStyle.lerp(codeSm, other.codeSm, t)!,
    );
  }
}
