import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

/// Switches the [Rise] entrance on or off for everything below it.
///
/// Typical use: wrap a screen in `UiRiseScope(enabled: firstVisitToday)` so the
/// staggered entrance plays once and not on every return to the screen.
/// Without a scope, [Rise] always animates.
class UiRiseScope extends StatelessWidget {
  const UiRiseScope({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  static bool animates(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RiseFlag>()?.on ?? true;

  @override
  Widget build(BuildContext context) => _RiseFlag(on: enabled, child: child);
}

class _RiseFlag extends InheritedWidget {
  const _RiseFlag({required this.on, required super.child});

  final bool on;

  @override
  bool updateShouldNotify(_RiseFlag old) => old.on != on;
}

/// Wraps each child in a [Rise] with an incrementing index so a column of
/// blocks enters one after another. Empty `SizedBox` spacers are left alone and
/// do not consume an index.
List<Widget> riseAll(List<Widget> children) {
  var i = 0;
  return [
    for (final c in children)
      c is SizedBox && c.child == null ? c : Rise(index: i++, child: c),
  ];
}

/// Fade + lift + settle entrance, delayed by [index] so siblings cascade.
/// Honors the OS "reduce motion" setting and [UiRiseScope].
class Rise extends StatefulWidget {
  const Rise({super.key, required this.index, required this.child});

  /// Position in the cascade. Delay grows with the index up to 7.
  final int index;
  final Widget child;

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  AnimationController? _c;
  Animation<double>? _v;
  bool? _animate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animate != null) return;
    final ui = context.ui;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _animate = UiRiseScope.animates(context) && !reduce;
    if (!_animate!) return;
    final delay =
        40 +
        widget.index.clamp(0, 7).toInt() * ui.motion.riseStagger.inMilliseconds;
    final motion = ui.motion.rise.inMilliseconds;
    final c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: delay + motion),
    );
    _c = c;
    _v = CurvedAnimation(
      parent: c,
      curve: Interval(delay / (delay + motion), 1, curve: Curves.easeOutCubic),
    );
    c.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _v;
    if (_animate != true || v == null) return widget.child;
    final distance = context.ui.motion.riseDistance;
    return AnimatedBuilder(
      animation: v,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: v.value,
        child: Transform.translate(
          offset: Offset(0, distance * (1 - v.value)),
          child: Transform.scale(scale: 0.97 + 0.03 * v.value, child: child),
        ),
      ),
    );
  }
}
