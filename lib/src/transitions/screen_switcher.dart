import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

/// Swaps whole screens with a directional fade / drift / scale, for apps that
/// keep their own routing state (a tab shell, a wizard, a master-detail pane).
/// Apps using `Navigator` get the same motion from `UiPageTransitionsBuilder`.
///
/// Direction is derived automatically:
/// * both the old and the new screen have an [index] (tabs): the content slides
///   **sideways**, toward the side of the tab you moved to;
/// * otherwise it moves **vertically**: forward when [depth] grows or stays the
///   same (drilling in), backward when it shrinks (going back).
///
/// ```dart
/// UiScreenSwitcher(
///   screenKey: route,           // changes => animate
///   index: tabIndex,            // null for non-tab screens
///   depth: stack.length,
///   child: buildScreen(route),
/// )
/// ```
class UiScreenSwitcher extends StatefulWidget {
  const UiScreenSwitcher({
    super.key,
    required this.screenKey,
    required this.child,
    this.index,
    this.depth = 0,
  });

  /// Identity of the current screen. A different key triggers the transition.
  final Object screenKey;

  /// Tab position, or null if the screen is not a tab.
  final int? index;

  /// Navigation depth, used for vertical direction when [index] is null.
  final int depth;

  final Widget child;

  @override
  State<UiScreenSwitcher> createState() => _UiScreenSwitcherState();
}

class _UiScreenSwitcherState extends State<UiScreenSwitcher> {
  // Not `late` initializers: those would run lazily, after the widget has
  // already changed, and the first transition would see no difference.
  late Object _lastKey;
  late int? _lastIndex;
  late int _lastDepth;
  bool _sideways = false;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _lastKey = widget.screenKey;
    _lastIndex = widget.index;
    _lastDepth = widget.depth;
  }

  @override
  void didUpdateWidget(UiScreenSwitcher old) {
    super.didUpdateWidget(old);
    if (widget.screenKey == _lastKey) return;
    final from = _lastIndex;
    final to = widget.index;
    _sideways = from != null && to != null;
    _forward = _sideways ? to! > from! : widget.depth >= _lastDepth;
    _lastKey = widget.screenKey;
    _lastIndex = to;
    _lastDepth = widget.depth;
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final sideways = _sideways;
    final dir = (_forward ? 1.0 : -1.0) * (sideways && rtl ? -1 : 1);
    final currentKey = ValueKey<Object>(widget.screenKey);

    return AnimatedSwitcher(
      duration: reduce ? Duration.zero : ui.motion.screen,
      switchInCurve: ui.motion.screenIn,
      switchOutCurve: ui.motion.screenOut,
      transitionBuilder: (child, animation) {
        final incoming = child.key == currentKey;
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (_, inner) {
            final v = animation.value.clamp(0.0, 1.0);
            final away = 1 - v;
            final m = ui.motion;
            final shift = sideways
                ? Offset(
                    (incoming ? m.screenShiftIn : -m.screenShiftOut) *
                        dir *
                        away,
                    0,
                  )
                : Offset(
                    0,
                    incoming
                        ? m.screenRiseIn * dir * away
                        : -m.screenRiseOut * dir * away,
                  );
            return Opacity(
              opacity: v,
              child: Transform.translate(
                offset: shift,
                child: Transform.scale(
                  scale: incoming ? 1 + 0.03 * away : 1 - 0.04 * away,
                  child: RepaintBoundary(child: inner),
                ),
              ),
            );
          },
        );
      },
      layoutBuilder: (current, previous) => Stack(
        children: [
          for (final c in previous) Positioned.fill(key: c.key, child: c),
          if (current != null)
            Positioned.fill(key: current.key, child: current),
        ],
      ),
      child: KeyedSubtree(key: currentKey, child: widget.child),
    );
  }
}
