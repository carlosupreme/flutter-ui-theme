import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

/// Shared math for the "fade + drift + settle" motion used by both
/// [UiPageTransitionsBuilder] and `UiScreenSwitcher`.
///
/// [animation] is the incoming progress (0..1). [away] is the outgoing
/// progress (0 = fully shown, 1 = fully gone).
Widget uiSettle({
  required Animation<double> animation,
  required Animation<double> away,
  required UiTheme ui,
  required Axis axis,
  required double direction,
  required Widget child,
}) {
  final m = ui.motion;
  return AnimatedBuilder(
    animation: Listenable.merge([animation, away]),
    child: child,
    builder: (context, kid) {
      final inV = m.screenIn.transform(animation.value.clamp(0.0, 1.0));
      final inAway = 1 - inV;
      final outV = m.screenOut.transform(away.value.clamp(0.0, 1.0));
      final shiftIn = axis == Axis.horizontal
          ? m.screenShiftIn
          : m.screenRiseIn;
      final shiftOut = axis == Axis.horizontal
          ? m.screenShiftOut
          : m.screenRiseOut;
      final shift = direction * (shiftIn * inAway - shiftOut * outV);
      return Opacity(
        opacity: (inV * (1 - 0.6 * outV)).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: axis == Axis.horizontal ? Offset(shift, 0) : Offset(0, shift),
          child: Transform.scale(
            scale: (1 + 0.03 * inAway) * (1 - 0.04 * outV),
            child: kid,
          ),
        ),
      );
    },
  );
}

/// Drop-in [PageTransitionsBuilder] with the same motion as `UiScreenSwitcher`.
/// `buildUiTheme` registers it for every platform, so `Navigator.push`,
/// `MaterialPageRoute` and go_router pages all pick it up automatically.
///
/// Full-screen dialogs rise vertically; normal pages drift sideways in the
/// reading direction (right-to-left languages are mirrored).
class UiPageTransitionsBuilder extends PageTransitionsBuilder {
  const UiPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 320);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) return FadeTransition(opacity: animation, child: child);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final vertical = route.fullscreenDialog;
    return uiSettle(
      animation: animation,
      away: secondaryAnimation,
      ui: context.ui,
      axis: vertical ? Axis.vertical : Axis.horizontal,
      direction: vertical || !rtl ? 1 : -1,
      child: child,
    );
  }
}
