import 'package:flutter/widgets.dart';

/// Blur strengths, scrims and shadows.
class UiEffects {
  const UiEffects({
    this.sheetBlur = 14,
    this.navBlur = 16,
    this.glassBlur = 22,
    this.sheetBarrierAlpha = 0.32,
    this.dialogBarrierAlpha = 0.36,
    this.navShadow = const BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    this.glowAlpha = 0.45,
    this.toastBackground = const Color(0xFF0B0B0B),
  });

  /// Background blur behind modal sheets and dialogs.
  final double sheetBlur;

  /// Blur inside the floating navigation bar.
  final double navBlur;

  /// Default blur of [UiGlassSurface].
  final double glassBlur;

  final double sheetBarrierAlpha;
  final double dialogBarrierAlpha;

  /// Drop shadow under floating chrome (nav bar, toast).
  final BoxShadow navShadow;

  /// Opacity of the colored glow under accent buttons.
  final double glowAlpha;

  final Color toastBackground;

  /// Colored glow used under the nav action button.
  List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: glowAlpha),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  /// Shadow for an element being dragged or lifted. [t] is 0 (resting) to 1.
  List<BoxShadow> lifted(double t, {double alpha = 0.35}) => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: alpha * t),
      blurRadius: 18 * t,
      offset: Offset(0, 8 * t),
    ),
  ];

  UiEffects copyWith({
    double? sheetBlur,
    double? navBlur,
    double? glassBlur,
    double? sheetBarrierAlpha,
    double? dialogBarrierAlpha,
    BoxShadow? navShadow,
    double? glowAlpha,
    Color? toastBackground,
  }) => UiEffects(
    sheetBlur: sheetBlur ?? this.sheetBlur,
    navBlur: navBlur ?? this.navBlur,
    glassBlur: glassBlur ?? this.glassBlur,
    sheetBarrierAlpha: sheetBarrierAlpha ?? this.sheetBarrierAlpha,
    dialogBarrierAlpha: dialogBarrierAlpha ?? this.dialogBarrierAlpha,
    navShadow: navShadow ?? this.navShadow,
    glowAlpha: glowAlpha ?? this.glowAlpha,
    toastBackground: toastBackground ?? this.toastBackground,
  );
}
