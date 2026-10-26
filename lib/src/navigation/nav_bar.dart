import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ui_theme.dart';
import '../widgets/pressable.dart';
import '../widgets/surfaces.dart';

/// One destination of [UiNavBar] / [UiNavRail].
@immutable
class UiNavItem {
  const UiNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge = 0,
    this.semanticLabel,
  });

  final IconData icon;

  /// Icon shown while selected (usually the filled variant of [icon]).
  final IconData? activeIcon;
  final String label;

  /// Unread count. Hidden at 0, shown as "99+" above 99.
  final int badge;
  final String? semanticLabel;
}

/// Prominent round button that sits among the items (e.g. "New appointment").
@immutable
class UiNavAction {
  const UiNavAction({
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  /// Spoken by screen readers, and shown as text by the extended [UiNavRail].
  final String? label;
}

/// Floating glass navigation bar with a liquid selection pill.
///
/// * Tap an item to select it. The pill stretches toward the new slot.
/// * Press and hold an item, then slide: the pill lifts and follows your finger
///   (or mouse), with haptic ticks on phones.
/// * Optionally embeds a [UiNavAction] between the items.
///
/// The bar is a fixed 74px tall and at most [maxWidth] wide, centered in the
/// space it is given. It always lays out left-to-right; reverse [items] for
/// right-to-left locales. For a ready-made bottom placement with blur and safe
/// areas, use `UiShell`.
class UiNavBar extends StatefulWidget {
  const UiNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.action,
    this.actionIndex,
    this.maxWidth = 460,
    this.haptics = true,
    this.unselectedColor,
  }) : assert(
         items.length >= 2 && items.length <= 6,
         'UiNavBar supports 2 to 6 items',
       );

  static const double height = 74;

  final List<UiNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Round button placed between items.
  final UiNavAction? action;

  /// Number of items to the left of [action]. Defaults to the middle.
  final int? actionIndex;
  final double maxWidth;
  final bool haptics;

  /// Color of unselected icons and labels. Defaults to `UiColors.textTertiary`;
  /// use `textSecondary` for stronger contrast.
  final Color? unselectedColor;

  @override
  State<UiNavBar> createState() => _UiNavBarState();
}

class _UiNavBarState extends State<UiNavBar> {
  static const _maxItemWidth = 58.0;
  static const _actionWidth = 54.0;

  double? _dragX;
  int? _hover;
  double _slotW = 0;
  double _itemW = _maxItemWidth;
  double _actionX = 0;
  List<double> _itemX = const [];

  int get _count => widget.items.length;
  int get _selected => _hover ?? widget.selectedIndex.clamp(0, _count - 1);
  int get _actionAt => (widget.actionIndex ?? _count ~/ 2).clamp(0, _count);

  void _tick() {
    if (widget.haptics) HapticFeedback.selectionClick();
  }

  int _nearest(double x) {
    var best = 0;
    for (var i = 1; i < _count; i++) {
      final distance = (_itemX[i] + _itemW / 2 - x).abs();
      if (distance < (_itemX[best] + _itemW / 2 - x).abs()) {
        best = i;
      }
    }
    return best;
  }

  void _dragTo(double x) {
    final near = _nearest(x);
    if (near != _hover) _tick();
    setState(() {
      _dragX = x.clamp(_itemW / 2, _slotW - _itemW / 2);
      _hover = near;
    });
  }

  void _dragEnd() {
    final target = _hover;
    setState(() {
      _dragX = null;
      _hover = null;
    });
    if (target != null && target != widget.selectedIndex) {
      widget.onSelected(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    final action = widget.action;
    final hasAction = action != null;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: SizedBox(
            height: UiNavBar.height,
            child: LayoutBuilder(
              builder: (context, box) {
                _slotW = box.maxWidth - 16;
                _itemW = ((_slotW - (hasAction ? _actionWidth : 0)) / _count)
                    .clamp(40.0, _maxItemWidth);
                final elements = _count + (hasAction ? 1 : 0);
                final itemsW = _count * _itemW + (hasAction ? _actionWidth : 0);
                final gap = elements > 1
                    ? ((_slotW - itemsW) / (elements - 1)).clamp(0.0, 40.0)
                    : 0.0;
                final origin = ((_slotW - (itemsW + gap * (elements - 1))) / 2)
                    .clamp(0.0, double.infinity);

                _itemX = List<double>.filled(_count, 0);
                var x = origin;
                final children = <Widget>[];
                for (var i = 0; i <= _count; i++) {
                  if (hasAction && i == _actionAt) {
                    _actionX = x;
                    x += _actionWidth + gap;
                    if (children.isNotEmpty) children.add(SizedBox(width: gap));
                    children.add(
                      _ActionButton(action: action, width: _actionWidth),
                    );
                  }
                  if (i < _count) {
                    _itemX[i] = x;
                    x += _itemW + gap;
                    if (children.isNotEmpty) children.add(SizedBox(width: gap));
                    children.add(_buildItem(i));
                  }
                }

                final drag = _dragX;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: ui.shape.navRadius,
                          boxShadow: [ui.effects.navShadow],
                        ),
                        child: UiGlassSurface(
                          radius: ui.shape.nav,
                          blur: ui.effects.navBlur,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: _LiquidPill(
                        left: _itemX[_selected],
                        dragLeft: drag == null ? null : drag - _itemW / 2,
                        width: _itemW,
                        duration: ui.motion.navPill,
                        color: c.text.withValues(alpha: ui.isDark ? 0.1 : 0.07),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: (d) {
                          if (hasAction &&
                              (d.localPosition.dx -
                                          (_actionX + _actionWidth / 2))
                                      .abs() <
                                  _actionWidth / 2 + 4) {
                            return;
                          }
                          _tick();
                          _dragTo(d.localPosition.dx);
                        },
                        onHorizontalDragUpdate: (d) {
                          if (_dragX != null) _dragTo(d.localPosition.dx);
                        },
                        onHorizontalDragEnd: (_) {
                          if (_dragX != null) _dragEnd();
                        },
                        onHorizontalDragCancel: () {
                          if (_dragX != null) _dragEnd();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: children,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = widget.items[index];
    final selected = _selected == index;
    return _NavItem(
      item: item,
      width: _itemW,
      selected: selected,
      lifted: selected && _dragX != null,
      unselectedColor: widget.unselectedColor,
      isCurrent: widget.selectedIndex == index,
      onTap: () {
        _tick();
        widget.onSelected(index);
      },
      onLongPressStart: (d) {
        if (widget.haptics) HapticFeedback.mediumImpact();
        _dragTo(_itemX[index] + d.localPosition.dx);
      },
      onLongPressMove: (d) => _dragTo(_itemX[index] + d.localPosition.dx),
      onLongPressEnd: _dragEnd,
      onLongPressCancel: () {
        if (_dragX != null) _dragEnd();
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.width,
    required this.selected,
    required this.lifted,
    required this.isCurrent,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMove,
    required this.onLongPressEnd,
    required this.onLongPressCancel,
    this.unselectedColor,
  });

  final UiNavItem item;
  final double width;
  final bool selected;
  final bool lifted;
  final bool isCurrent;
  final Color? unselectedColor;
  final VoidCallback onTap;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMove;
  final VoidCallback onLongPressEnd;
  final VoidCallback onLongPressCancel;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    final item = widget.item;
    final color = widget.selected
        ? c.text
        : (widget.unselectedColor ?? c.textTertiary);
    const dur = Duration(milliseconds: 300);

    Widget icon = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: dur,
      curve: Curves.easeOut,
      builder: (context, value, _) => Icon(
        widget.selected ? (item.activeIcon ?? item.icon) : item.icon,
        size: 22,
        color: value,
      ),
    );
    if (item.badge > 0) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            top: -5,
            right: -9,
            child: Container(
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.danger,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.badge > 99 ? '99+' : '${item.badge}',
                style: ui.typography.strong(
                  9,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        selected: widget.isCurrent,
        label: item.semanticLabel ?? item.label,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPressStart: widget.onLongPressStart,
          onLongPressMoveUpdate: widget.onLongPressMove,
          onLongPressEnd: (_) => widget.onLongPressEnd(),
          onLongPressCancel: widget.onLongPressCancel,
          child: AnimatedScale(
            scale: widget.lifted ? 1.06 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: _focused ? Border.all(color: c.accent, width: 2) : null,
              ),
              child: SizedBox(
                width: widget.width,
                height: UiNavBar.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: dur,
                          curve: Curves.easeOut,
                          style: ui.typography.body(
                            10,
                            weight: FontWeight.w600,
                            color: color,
                            letterSpacing: 0.2,
                          ),
                          child: Text(item.label, maxLines: 1, softWrap: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.width});

  final UiNavAction action;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Center(
      child: UiPressable(
        onTap: action.onPressed,
        onLongPress: action.onLongPress,
        haptic: true,
        scale: 0.92,
        semanticLabel: action.label,
        focusRadius: BorderRadius.circular(width),
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ui.colors.accent, ui.colors.accentAlt],
            ),
            shape: BoxShape.circle,
            boxShadow: ui.effects.glow(ui.colors.accent),
          ),
          child: Icon(action.icon, size: 24, color: ui.colors.background),
        ),
      ),
    );
  }
}

/// The selection highlight: when the target changes, the leading edge races
/// ahead and the trailing edge catches up, so the pill stretches like a drop of
/// liquid. While dragging it lifts, grows and picks up a shadow.
class _LiquidPill extends StatefulWidget {
  const _LiquidPill({
    required this.left,
    required this.width,
    required this.color,
    required this.duration,
    this.dragLeft,
  });

  final double left;
  final double? dragLeft;
  final double width;
  final Color color;
  final Duration duration;

  @override
  State<_LiquidPill> createState() => _LiquidPillState();
}

class _LiquidPillState extends State<_LiquidPill>
    with TickerProviderStateMixin {
  static const _liftCurve = Cubic(0.3, 1.25, 0.5, 1);

  late final AnimationController _move;
  late final AnimationController _lift;
  late double _from;
  late double _shown;

  @override
  void initState() {
    super.initState();
    _move = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    );
    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 380),
    );
    _from = widget.left;
    _shown = widget.left;
  }

  @override
  void didUpdateWidget(_LiquidPill old) {
    super.didUpdateWidget(old);
    _move.duration = widget.duration;
    final dragging = widget.dragLeft != null;
    if (dragging != (old.dragLeft != null)) {
      dragging ? _lift.forward() : _lift.reverse();
    }
    if (dragging) return;
    if (old.left == widget.left && old.dragLeft == null) return;
    _from = _shown;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _from = widget.left;
      _move.value = 1;
    } else {
      _move.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _move.dispose();
    _lift.dispose();
    super.dispose();
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_move, _lift]),
      builder: (context, _) {
        final lift = _liftCurve.transform(_lift.value.clamp(0.0, 1.0));
        final double l, r;
        var squash = 1.0;
        final drag = widget.dragLeft;
        if (drag != null) {
          l = drag;
          r = drag + widget.width;
        } else {
          final t = _move.value;
          final to = widget.left;
          final right = to >= _from;
          final lead = Curves.easeOutCubic.transform(t);
          final trail = Curves.easeInOutCubic.transform(t);
          l = _lerp(_from, to, right ? trail : lead);
          r = _lerp(
            _from + widget.width,
            to + widget.width,
            right ? lead : trail,
          );
          squash = 1 - 0.14 * (1 - (2 * t - 1).abs()) * (to == _from ? 0 : 1);
        }
        _shown = l;
        final base = Color.lerp(
          widget.color,
          widget.color.withValues(
            alpha: (widget.color.a * 2.4).clamp(0.0, 1.0),
          ),
          lift,
        )!;
        final grow = 6 * lift;
        final inset = 10 + 12 * (1 - squash) - 6 * lift;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: l - grow,
              width: r - l + 2 * grow,
              top: inset,
              bottom: inset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16 * lift),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.alphaBlend(
                        Colors.white.withValues(alpha: 0.12 * lift),
                        base,
                      ),
                      base,
                    ],
                  ),
                  boxShadow: lift <= 0
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28 * lift),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
