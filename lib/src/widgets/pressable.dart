import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ui_theme.dart';

/// Tap target with the signature springy press: it shrinks quickly while held
/// and overshoots back on release. It is the base of every button here, and
/// works with mouse, touch and keyboard:
///
/// * pointer cursor on hover (desktop),
/// * Enter / Space activate it, with an accent focus ring,
/// * reports itself as a button to screen readers.
///
/// A `null` [onTap] disables it.
class UiPressable extends StatefulWidget {
  const UiPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.scale,
    this.haptic = false,
    this.semanticLabel,
    this.focusRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Pressed scale. Defaults to `UiMotion.pressScale`.
  final double? scale;

  /// Fire a selection haptic on tap (phones only; a no-op on desktop).
  final bool haptic;

  /// Overrides the label read by screen readers.
  final String? semanticLabel;

  /// Corner radius of the keyboard focus ring. Defaults to a pill.
  final BorderRadius? focusRadius;

  @override
  State<UiPressable> createState() => _UiPressableState();
}

class _UiPressableState extends State<UiPressable> {
  bool _down = false;
  bool _focused = false;

  void _setDown(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  void _tap() {
    if (widget.haptic) HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final enabled = widget.onTap != null;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final pressed = _down && !reduce;

    Widget body = AnimatedScale(
      scale: pressed ? (widget.scale ?? ui.motion.pressScale) : 1,
      duration: reduce
          ? Duration.zero
          : (_down ? ui.motion.pressDown : ui.motion.pressUp),
      curve: _down ? Curves.easeOut : ui.motion.pressReleaseCurve,
      child: widget.child,
    );
    if (_focused) {
      body = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: widget.focusRadius ?? ui.shape.pillRadius,
          border: Border.all(color: ui.colors.accent, width: 2),
        ),
        child: body,
      );
    }

    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _tap();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _tap : null,
          onLongPress: widget.onLongPress,
          onTapDown: enabled ? (_) => _setDown(true) : null,
          onTapUp: (_) => _setDown(false),
          onTapCancel: () => _setDown(false),
          child: body,
        ),
      ),
    );
  }
}
