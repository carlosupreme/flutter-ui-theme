import 'dart:ui' as ui_;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

final _open = ValueNotifier<int>(0);
final _shown = ValueNotifier<int>(0);

/// Number of glass sheets/dialogs that are currently open (not closing).
/// Use it to, for example, hide a floating button while a modal is up.
ValueListenable<int> get uiGlassOpenCount => _open;

/// Number of glass routes still on screen, including ones animating out.
ValueListenable<int> get uiGlassShownCount => _shown;

/// Width from which [showUiSheet] presents a centered panel instead of a
/// bottom sheet.
const double kUiSheetDesktopBreakpoint = 720;

mixin _GlassCount<T> on ModalRoute<T> {
  static final _live = <_GlassCount>{};

  bool _isOpen = false;
  bool _handoff = false;
  bool _handedOff = false;

  /// When one glass route replaces another, the new one starts fully blurred
  /// and the old one stops blurring, so the backdrop never flickers.
  bool get blurFull => _handoff;
  bool get blurOff => _handedOff;

  @override
  void install() {
    super.install();
    final closing = _live.where((r) => !r._isOpen);
    if (_open.value == 0 && closing.isNotEmpty) {
      _handoff = true;
      for (final r in closing) {
        r._handedOff = true;
      }
    }
    _isOpen = true;
    _live.add(this);
    _open.value++;
    _shown.value++;
  }

  void _close() {
    if (!_isOpen) return;
    _isOpen = false;
    _open.value--;
  }

  @override
  bool didPop(T? result) {
    _close();
    return super.didPop(result);
  }

  @override
  void dispose() {
    _close();
    if (_live.remove(this)) _shown.value--;
    super.dispose();
  }
}

/// Modal sheet over a blurred, dimmed backdrop. Pull down past the top of a
/// scrollable body to dismiss.
///
/// On wide windows ([kUiSheetDesktopBreakpoint]) with [adaptive] true it shows
/// as a centered panel (max [desktopMaxWidth]) rather than a bottom sheet, which
/// is the right pattern on desktop.
Future<T?> showUiSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  ShapeBorder? shape,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  bool adaptive = true,
  double desktopMaxWidth = 520,
}) {
  final size = MediaQuery.sizeOf(context);
  if (adaptive && size.width >= kUiSheetDesktopBreakpoint) {
    return showUiDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (c) {
        final ui = c.ui;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: desktopMaxWidth,
                maxHeight: size.height * 0.88,
              ),
              child: Material(
                color: backgroundColor ?? ui.colors.surface,
                shape:
                    shape ??
                    RoundedRectangleBorder(borderRadius: ui.shape.sheetRadius),
                clipBehavior: Clip.antiAlias,
                child: builder(c),
              ),
            ),
          ),
        );
      },
    );
  }

  final nav = Navigator.of(context);
  final ui = context.ui;
  return nav.push(
    _GlassSheetRoute<T>(
      blurSigma: ui.effects.sheetBlur,
      builder: enableDrag && isDismissible
          ? (c) => _PullToClose(child: builder(c))
          : builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: shape,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      modalBarrierColor: Colors.black.withValues(
        alpha: ui.effects.sheetBarrierAlpha,
      ),
      capturedThemes: InheritedTheme.capture(from: context, to: nav.context),
      barrierLabel: MaterialLocalizations.of(context).scrimLabel,
    ),
  );
}

class _GlassSheetRoute<T> extends ModalBottomSheetRoute<T> with _GlassCount<T> {
  _GlassSheetRoute({
    required this.blurSigma,
    required super.builder,
    required super.isScrollControlled,
    super.backgroundColor,
    super.shape,
    super.isDismissible,
    super.enableDrag,
    super.useSafeArea,
    super.modalBarrierColor,
    super.capturedThemes,
    super.barrierLabel,
  });

  final double blurSigma;

  @override
  Widget buildModalBarrier() => _BlurBarrier(
    route: this,
    sigma: blurSigma,
    animation: animation!,
    child: super.buildModalBarrier(),
  );
}

class _PullToClose extends StatefulWidget {
  const _PullToClose({required this.child});

  final Widget child;

  @override
  State<_PullToClose> createState() => _PullToCloseState();
}

class _PullToCloseState extends State<_PullToClose> {
  static const _limit = 72.0;
  double _pull = 0;
  bool _closing = false;

  void _set(double v) {
    if (v == _pull || _closing) return;
    setState(() => _pull = v);
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).maybePop();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is OverscrollNotification &&
        n.dragDetails != null &&
        n.overscroll < 0 &&
        n.metrics.extentBefore == 0) {
      final next = _pull - n.overscroll;
      if (next > _limit) {
        _close();
      } else {
        _set(next);
      }
    } else if (n is ScrollUpdateNotification && n.dragDetails != null) {
      if (n.metrics.pixels < -_limit) {
        _close();
      } else if ((n.scrollDelta ?? 0) > 0) {
        _set(0);
      }
    } else if (n is ScrollEndNotification) {
      _set(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Transform.translate(
          offset: Offset(0, _pull * 0.5),
          child: widget.child,
        ),
      );
}

/// Modal dialog over a blurred, dimmed backdrop; the dialog scales and fades in
/// with a small overshoot.
Future<T?> showUiDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final nav = Navigator.of(context);
  final ui = context.ui;
  return nav.push(
    _GlassDialogRoute<T>(
      context: context,
      builder: builder,
      blurSigma: ui.effects.sheetBlur,
      scaleFrom: ui.motion.dialogScaleFrom,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(
        alpha: ui.effects.dialogBarrierAlpha,
      ),
      themes: InheritedTheme.capture(from: context, to: nav.context),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    ),
  );
}

class _GlassDialogRoute<T> extends DialogRoute<T> with _GlassCount<T> {
  _GlassDialogRoute({
    required super.context,
    required super.builder,
    required this.blurSigma,
    required this.scaleFrom,
    super.barrierDismissible,
    super.barrierColor,
    super.themes,
    super.barrierLabel,
  });

  final double blurSigma;
  final double scaleFrom;

  @override
  Widget buildModalBarrier() => _BlurBarrier(
    route: this,
    sigma: blurSigma,
    animation: animation!,
    child: super.buildModalBarrier(),
  );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return FadeTransition(opacity: animation, child: child);
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween<double>(begin: scaleFrom, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}

class _BlurBarrier extends StatelessWidget {
  const _BlurBarrier({
    required this.route,
    required this.sigma,
    required this.animation,
    required this.child,
  });

  final _GlassCount route;
  final double sigma;
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, barrier) {
        if (route.blurOff) return barrier!;
        final full =
            route.blurFull && animation.status != AnimationStatus.reverse;
        final s = full
            ? sigma
            : sigma * Curves.easeOut.transform(animation.value.clamp(0.0, 1.0));
        if (s < 0.3) return barrier!;
        return BackdropFilter(
          filter: ui_.ImageFilter.blur(sigmaX: s, sigmaY: s),
          child: barrier,
        );
      },
    );
  }
}
