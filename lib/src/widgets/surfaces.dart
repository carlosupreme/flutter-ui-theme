import 'dart:ui' as ui_;

import 'package:flutter/material.dart';

import '../overlays/glass_routes.dart' show kUiSheetDesktopBreakpoint;
import '../tokens/ui_theme.dart';
import 'pressable.dart';

/// Flat rounded container with a hairline border: the default "card".
/// Pass [onTap] to make the whole card a springy button.
class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius,
    this.borderColor,
    this.color,
    this.clip = false,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Defaults to `UiShape.card`.
  final double? radius;
  final Color? borderColor;
  final Color? color;
  final bool clip;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final r = BorderRadius.circular(radius ?? ui.shape.card);
    final card = Container(
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color ?? ui.colors.surface,
        border: Border.all(color: borderColor ?? ui.colors.border),
        borderRadius: r,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return UiPressable(
      onTap: onTap,
      scale: 0.985,
      semanticLabel: semanticLabel,
      focusRadius: r,
      child: card,
    );
  }
}

/// Frosted-glass panel: blurred backdrop, translucent tint, a soft top
/// highlight and a hairline edge. Put it over content or a gradient to see the
/// effect; over a flat color it just looks like a tinted card.
class UiGlassSurface extends StatelessWidget {
  const UiGlassSurface({
    super.key,
    required this.child,
    this.radius,
    this.blur,
    this.tint,
    this.padding,
  });

  final Widget child;

  /// Defaults to `UiShape.sheet`.
  final double? radius;

  /// Defaults to `UiEffects.glassBlur`.
  final double? blur;

  /// Overrides the translucent fill.
  final Color? tint;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final dark = ui.isDark;
    final shape = BorderRadius.circular(radius ?? ui.shape.sheet);
    final sigma = blur ?? ui.effects.glassBlur;
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter.grouped(
        filter: ui_.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape,
            color:
                tint ?? ui.colors.surface.withValues(alpha: dark ? 0.66 : 0.74),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: shape,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: dark ? 0.07 : 0.3),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.6],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: dark ? 0.08 : 0.5),
                width: 0.8,
              ),
            ),
            child: padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}

/// Small rounded label with an optional icon, e.g. "Beta", "New", "Urgent".
class UiBadge extends StatelessWidget {
  const UiBadge(
    this.label, {
    super.key,
    this.icon,
    this.color,
    this.small = false,
  });

  final String label;
  final IconData? icon;

  /// Defaults to `UiColors.accent`.
  final Color? color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = color ?? ui.colors.accent;
    return Container(
      padding: EdgeInsets.fromLTRB(
        small ? 6 : 7,
        small ? 2 : 3,
        small ? 7 : 8,
        small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: ui.shape.pillRadius,
        border: Border.all(color: c.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 9 : 10.5, color: c),
            const SizedBox(width: 3),
          ],
          Text(
            label.toUpperCase(),
            style: ui.typography.strong(
              small ? 8.5 : 9.5,
              weight: FontWeight.w800,
              color: c,
              letterSpacing: 1.1,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grabber shown at the top of a bottom sheet.
class UiSheetHandle extends StatelessWidget {
  const UiSheetHandle({super.key, this.color, this.margin});

  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // Desktop sheets are centered panels, which are not dragged down: no grabber.
    if (MediaQuery.sizeOf(context).width >= kUiSheetDesktopBreakpoint) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? context.ui.colors.surfaceAlt,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Centered title (and optional subtitle) for a sheet or dialog body.
class UiSheetTitle extends StatelessWidget {
  const UiSheetTitle(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: ui.typography.strong(17, color: ui.colors.text),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: ui.typography.strong(
              12,
              weight: FontWeight.w500,
              color: ui.colors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standard padding for sheet content, including the bottom safe area.
EdgeInsets uiSheetPadding(BuildContext context, {double bottom = 28}) =>
    EdgeInsets.fromLTRB(
      20,
      12,
      20,
      bottom + MediaQuery.paddingOf(context).bottom,
    );

/// Dot or line grid drawn behind a screen. Subtle texture for empty or
/// dashboard backgrounds.
enum UiPattern { dots, grid }

class UiPatternBackground extends StatelessWidget {
  const UiPatternBackground({
    super.key,
    this.pattern = UiPattern.dots,
    this.color,
  });

  final UiPattern pattern;

  /// Defaults to `UiColors.border`.
  final Color? color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PatternPainter(pattern, color ?? context.ui.colors.border),
      ),
    ),
  );
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.pattern, this.color);

  final UiPattern pattern;
  final Color color;
  static const _gap = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == UiPattern.dots) {
      canvas.drawPoints(
        ui_.PointMode.points,
        [
          for (double y = _gap; y < size.height; y += _gap)
            for (double x = _gap; x < size.width; x += _gap) Offset(x, y),
        ],
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawPoints(
        ui_.PointMode.lines,
        [
          for (double x = _gap; x < size.width; x += _gap) ...[
            Offset(x, 0),
            Offset(x, size.height),
          ],
          for (double y = _gap; y < size.height; y += _gap) ...[
            Offset(0, y),
            Offset(size.width, y),
          ],
        ],
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.pattern != pattern || old.color != color;
}

/// Skeleton placeholder with a single sweeping highlight. Size it with a
/// parent (`SizedBox`, `Expanded`, ...).
class UiShimmer extends StatefulWidget {
  const UiShimmer({super.key, this.radius = 16, this.repeat = false});

  final double radius;

  /// Loop forever (for long loads) instead of sweeping once.
  final bool repeat;

  @override
  State<UiShimmer> createState() => _UiShimmerState();
}

class _UiShimmerState extends State<UiShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      widget.repeat ? _c.repeat() : _c.repeat(count: 1);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ui.colors;
    final base = c.surfaceAlt;
    final shine = Color.lerp(c.surfaceAlt, c.text, 0.07)!;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = -1.6 + 3.2 * Curves.easeInOutSine.transform(_c.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 0.8, -0.3),
              end: Alignment(x + 0.8, 0.3),
              colors: [base, shine, base],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
