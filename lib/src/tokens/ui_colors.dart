import 'package:flutter/material.dart';

/// Semantic color palette. Every widget in this package reads colors from here,
/// so changing a value restyles the whole UI.
///
/// Naming:
/// * [primary] is the high-emphasis fill (primary buttons, selected segments,
///   switches). In the built-in palettes it is monochrome (white on dark,
///   near-black on light); brands usually override it.
/// * [accent] is the highlight color (links, focus ring, FAB gradient start).
@immutable
class UiColors {
  const UiColors({
    required this.pageBackground,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.navBackground,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primaryDeep,
    required this.onPrimary,
    required this.primarySoft,
    required this.primaryShadow,
    required this.accent,
    required this.accentAlt,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.muted,
    required this.info,
    required this.warning,
    required this.danger,
  });

  /// Backdrop behind the whole app (visible around floating shells).
  final Color pageBackground;

  /// Scaffold background.
  final Color background;

  /// Cards, sheets and dialogs.
  final Color surface;

  /// Controls sitting on a [surface]: secondary buttons, option groups, inputs.
  final Color surfaceAlt;

  final Color border;
  final Color navBackground;

  final Color text;
  final Color textSecondary;
  final Color textTertiary;

  final Color primary;
  final Color primaryDeep;
  final Color onPrimary;
  final Color primarySoft;
  final Color primaryShadow;

  final Color accent;

  /// Second stop of the accent gradient (the nav action button).
  final Color accentAlt;
  final Color accentSoft;

  final Color success;
  final Color successSoft;

  /// Neutral fill for skeletons, disabled areas and empty states.
  final Color muted;

  final Color info;
  final Color warning;
  final Color danger;

  static const dark = UiColors(
    pageBackground: Color(0xFF0A0908),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1C1C1C),
    surfaceAlt: Color(0xFF2B2B2B),
    border: Color(0xFF3E3E3E),
    navBackground: Color(0xD90A0A0A),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9A9A9A),
    textTertiary: Color(0xFF666666),
    primary: Color(0xFFFFFFFF),
    primaryDeep: Color(0xFFD0D0D0),
    onPrimary: Color(0xFF0A0A0A),
    primarySoft: Color(0x1AFFFFFF),
    primaryShadow: Color(0x80000000),
    accent: Color(0xFFD9A184),
    accentAlt: Color(0xFFB98F72),
    accentSoft: Color(0x29D9A184),
    success: Color(0xFF8FA377),
    successSoft: Color(0x298FA377),
    muted: Color(0xFF2A2A2A),
    info: Color(0xFF7FA8C9),
    warning: Color(0xFFE0B15A),
    danger: Color(0xFFE5674C),
  );

  static const amoled = UiColors(
    pageBackground: Color(0xFF000000),
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    surfaceAlt: Color(0xFF1E1E1E),
    border: Color(0xFF2E2E2E),
    navBackground: Color(0xE6000000),
    text: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9A9A9A),
    textTertiary: Color(0xFF666666),
    primary: Color(0xFFFFFFFF),
    primaryDeep: Color(0xFFD0D0D0),
    onPrimary: Color(0xFF000000),
    primarySoft: Color(0x1AFFFFFF),
    primaryShadow: Color(0x80000000),
    accent: Color(0xFFD9A184),
    accentAlt: Color(0xFFB98F72),
    accentSoft: Color(0x29D9A184),
    success: Color(0xFF8FA377),
    successSoft: Color(0x298FA377),
    muted: Color(0xFF1A1A1A),
    info: Color(0xFF7FA8C9),
    warning: Color(0xFFE0B15A),
    danger: Color(0xFFE5674C),
  );

  static const light = UiColors(
    pageBackground: Color(0xFFFFFEFD),
    background: Color(0xFFF7F4F0),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFECE8E3),
    border: Color(0xFFE0DBD5),
    navBackground: Color(0xF2FFFEFD),
    text: Color(0xFF1A1713),
    textSecondary: Color(0xFF5F574F),
    textTertiary: Color(0xFF8A8179),
    primary: Color(0xFF1A1713),
    primaryDeep: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0x121A1713),
    primaryShadow: Color(0x1F1A1713),
    accent: Color(0xFF9E4E27),
    accentAlt: Color(0xFF8A6B41),
    accentSoft: Color(0x1F9E4E27),
    success: Color(0xFF3D7A52),
    successSoft: Color(0x1F3D7A52),
    muted: Color(0xFFE9E4DE),
    info: Color(0xFF3268A0),
    warning: Color(0xFF9A6A12),
    danger: Color(0xFFC0392B),
  );

  /// True when [background] is dark enough to need light-on-dark treatments.
  bool get isDark => background.computeLuminance() < 0.5;

  UiColors copyWith({
    Color? pageBackground,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? navBackground,
    Color? text,
    Color? textSecondary,
    Color? textTertiary,
    Color? primary,
    Color? primaryDeep,
    Color? onPrimary,
    Color? primarySoft,
    Color? primaryShadow,
    Color? accent,
    Color? accentAlt,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? muted,
    Color? info,
    Color? warning,
    Color? danger,
  }) {
    return UiColors(
      pageBackground: pageBackground ?? this.pageBackground,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      navBackground: navBackground ?? this.navBackground,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      primary: primary ?? this.primary,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryShadow: primaryShadow ?? this.primaryShadow,
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      muted: muted ?? this.muted,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  static UiColors lerp(UiColors a, UiColors b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return UiColors(
      pageBackground: c(a.pageBackground, b.pageBackground),
      background: c(a.background, b.background),
      surface: c(a.surface, b.surface),
      surfaceAlt: c(a.surfaceAlt, b.surfaceAlt),
      border: c(a.border, b.border),
      navBackground: c(a.navBackground, b.navBackground),
      text: c(a.text, b.text),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textTertiary: c(a.textTertiary, b.textTertiary),
      primary: c(a.primary, b.primary),
      primaryDeep: c(a.primaryDeep, b.primaryDeep),
      onPrimary: c(a.onPrimary, b.onPrimary),
      primarySoft: c(a.primarySoft, b.primarySoft),
      primaryShadow: c(a.primaryShadow, b.primaryShadow),
      accent: c(a.accent, b.accent),
      accentAlt: c(a.accentAlt, b.accentAlt),
      accentSoft: c(a.accentSoft, b.accentSoft),
      success: c(a.success, b.success),
      successSoft: c(a.successSoft, b.successSoft),
      muted: c(a.muted, b.muted),
      info: c(a.info, b.info),
      warning: c(a.warning, b.warning),
      danger: c(a.danger, b.danger),
    );
  }
}
