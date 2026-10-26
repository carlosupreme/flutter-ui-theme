import 'package:flutter/animation.dart';

/// Durations, curves and distances for every animation in the package.
///
/// Widgets additionally respect `MediaQuery.disableAnimations` (the OS
/// "reduce motion" setting) and skip movement when it is on.
class UiMotion {
  const UiMotion({
    this.pressScale = 0.965,
    this.pressDown = const Duration(milliseconds: 90),
    this.pressUp = const Duration(milliseconds: 260),
    this.pressReleaseCurve = Curves.easeOutBack,
    this.screen = const Duration(milliseconds: 380),
    this.screenIn = const Interval(0.3, 1, curve: Curves.easeOutCubic),
    this.screenOut = const Interval(0.7, 1, curve: Curves.easeInCubic),
    this.screenShiftIn = 26,
    this.screenShiftOut = 18,
    this.screenRiseIn = 22,
    this.screenRiseOut = 8,
    this.rise = const Duration(milliseconds: 560),
    this.riseStagger = const Duration(milliseconds: 70),
    this.riseDistance = 22,
    this.navPill = const Duration(milliseconds: 460),
    this.overlay = const Duration(milliseconds: 280),
    this.dialogScaleFrom = 0.92,
  });

  /// Scale applied while a pressable is held down.
  final double pressScale;
  final Duration pressDown;
  final Duration pressUp;
  final Curve pressReleaseCurve;

  /// Screen-to-screen switch ([UiScreenSwitcher] and page transitions).
  final Duration screen;
  final Curve screenIn;
  final Curve screenOut;
  final double screenShiftIn;
  final double screenShiftOut;
  final double screenRiseIn;
  final double screenRiseOut;

  /// Staggered entrance of content blocks ([Rise]).
  final Duration rise;
  final Duration riseStagger;
  final double riseDistance;

  /// The liquid selection pill of the navigation bar.
  final Duration navPill;

  /// Toasts and generic overlays.
  final Duration overlay;
  final double dialogScaleFrom;

  UiMotion copyWith({
    double? pressScale,
    Duration? pressDown,
    Duration? pressUp,
    Curve? pressReleaseCurve,
    Duration? screen,
    Curve? screenIn,
    Curve? screenOut,
    double? screenShiftIn,
    double? screenShiftOut,
    double? screenRiseIn,
    double? screenRiseOut,
    Duration? rise,
    Duration? riseStagger,
    double? riseDistance,
    Duration? navPill,
    Duration? overlay,
    double? dialogScaleFrom,
  }) => UiMotion(
    pressScale: pressScale ?? this.pressScale,
    pressDown: pressDown ?? this.pressDown,
    pressUp: pressUp ?? this.pressUp,
    pressReleaseCurve: pressReleaseCurve ?? this.pressReleaseCurve,
    screen: screen ?? this.screen,
    screenIn: screenIn ?? this.screenIn,
    screenOut: screenOut ?? this.screenOut,
    screenShiftIn: screenShiftIn ?? this.screenShiftIn,
    screenShiftOut: screenShiftOut ?? this.screenShiftOut,
    screenRiseIn: screenRiseIn ?? this.screenRiseIn,
    screenRiseOut: screenRiseOut ?? this.screenRiseOut,
    rise: rise ?? this.rise,
    riseStagger: riseStagger ?? this.riseStagger,
    riseDistance: riseDistance ?? this.riseDistance,
    navPill: navPill ?? this.navPill,
    overlay: overlay ?? this.overlay,
    dialogScaleFrom: dialogScaleFrom ?? this.dialogScaleFrom,
  );
}
