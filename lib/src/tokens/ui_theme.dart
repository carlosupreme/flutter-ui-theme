import 'package:flutter/material.dart';

import 'ui_colors.dart';
import 'ui_effects.dart';
import 'ui_motion.dart';
import 'ui_shape.dart';
import 'ui_typography.dart';

/// The single design-token bundle. Register it on `ThemeData.extensions`
/// (done for you by `buildUiTheme`) and read it anywhere with `context.ui`.
///
/// ```dart
/// final ui = UiTheme.light.copyWith(
///   colors: UiColors.light.copyWith(primary: const Color(0xFF0F5C6E)),
/// );
/// MaterialApp(theme: buildUiTheme(ui));
/// ```
@immutable
class UiTheme extends ThemeExtension<UiTheme> {
  const UiTheme({
    required this.colors,
    this.shape = const UiShape(),
    this.motion = const UiMotion(),
    this.typography = const UiTypography(),
    this.effects = const UiEffects(),
  });

  static const light = UiTheme(colors: UiColors.light);
  static const dark = UiTheme(colors: UiColors.dark);
  static const amoled = UiTheme(colors: UiColors.amoled);

  final UiColors colors;
  final UiShape shape;
  final UiMotion motion;
  final UiTypography typography;
  final UiEffects effects;

  bool get isDark => colors.isDark;

  @override
  UiTheme copyWith({
    UiColors? colors,
    UiShape? shape,
    UiMotion? motion,
    UiTypography? typography,
    UiEffects? effects,
  }) => UiTheme(
    colors: colors ?? this.colors,
    shape: shape ?? this.shape,
    motion: motion ?? this.motion,
    typography: typography ?? this.typography,
    effects: effects ?? this.effects,
  );

  @override
  UiTheme lerp(ThemeExtension<UiTheme>? other, double t) {
    if (other is! UiTheme) return this;
    return UiTheme(
      colors: UiColors.lerp(colors, other.colors, t),
      shape: UiShape.lerp(shape, other.shape, t),
      motion: t < 0.5 ? motion : other.motion,
      typography: t < 0.5 ? typography : other.typography,
      effects: t < 0.5 ? effects : other.effects,
    );
  }
}

extension UiThemeContext on BuildContext {
  /// The active [UiTheme]. Falls back to the built-in light or dark tokens when
  /// the app's theme was not created with `buildUiTheme`, so widgets from this
  /// package never crash on a stock `ThemeData`.
  UiTheme get ui =>
      Theme.of(this).extension<UiTheme>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? UiTheme.dark
          : UiTheme.light);
}
