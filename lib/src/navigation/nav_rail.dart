import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';
import '../widgets/pressable.dart';
import '../widgets/surfaces.dart';
import 'nav_bar.dart';

/// Vertical glass navigation for desktop and tablet windows, the wide-screen
/// counterpart of [UiNavBar]. Collapsed it shows icon + small label; with
/// [extended] it shows icon + full label beside it.
class UiNavRail extends StatelessWidget {
  const UiNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.action,
    this.extended = false,
    this.leading,
    this.trailing,
  });

  final List<UiNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Prominent button shown above the items.
  final UiNavAction? action;
  final bool extended;

  /// Placed at the top (logo, clinic name).
  final Widget? leading;

  /// Placed at the bottom (profile, settings).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: extended ? 232 : 88,
      child: UiGlassSurface(
        radius: ui.shape.nav,
        blur: ui.effects.navBlur,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (leading != null) ...[
                Center(child: leading!),
                const SizedBox(height: 18),
              ],
              if (action != null) ...[
                _RailAction(action: action!, extended: extended),
                const SizedBox(height: 14),
              ],
              for (var i = 0; i < items.length; i++) ...[
                _RailItem(
                  item: items[i],
                  selected: i == selectedIndex,
                  extended: extended,
                  onTap: () => onSelected(i),
                ),
                const SizedBox(height: 4),
              ],
              const Spacer(),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final UiNavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    final color = selected ? c.text : c.textSecondary;
    final icon = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected ? (item.activeIcon ?? item.icon) : item.icon,
          size: 22,
          color: color,
        ),
        if (item.badge > 0)
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
    final radius = BorderRadius.circular(20);
    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: extended ? 50 : 62,
      padding: EdgeInsets.symmetric(horizontal: extended ? 16 : 4),
      decoration: BoxDecoration(
        color: selected
            ? c.text.withValues(alpha: ui.isDark ? 0.1 : 0.07)
            : Colors.transparent,
        borderRadius: radius,
      ),
      child: extended
          ? Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ui.typography.strong(
                      14,
                      weight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: ui.typography.body(
                      10,
                      weight: FontWeight.w600,
                      color: color,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
    );
    return Semantics(
      selected: selected,
      child: UiPressable(
        onTap: onTap,
        scale: 0.97,
        semanticLabel: item.semanticLabel ?? item.label,
        focusRadius: radius,
        child: extended
            ? body
            : Tooltip(
                message: item.label,
                waitDuration: const Duration(milliseconds: 500),
                child: body,
              ),
      ),
    );
  }
}

class _RailAction extends StatelessWidget {
  const _RailAction({required this.action, required this.extended});

  final UiNavAction action;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final showLabel = extended && action.label != null;
    final button = UiPressable(
      onTap: action.onPressed,
      onLongPress: action.onLongPress,
      scale: 0.94,
      semanticLabel: action.label,
      focusRadius: BorderRadius.circular(showLabel ? 100 : 54),
      child: Container(
        height: 54,
        width: showLabel ? double.infinity : 54,
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 18 : 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ui.colors.accent, ui.colors.accentAlt],
          ),
          borderRadius: BorderRadius.circular(showLabel ? 100 : 27),
          boxShadow: ui.effects.glow(ui.colors.accent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 22, color: ui.colors.background),
            if (showLabel) ...[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  action.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ui.typography.strong(
                    14.5,
                    weight: FontWeight.w800,
                    color: ui.colors.background,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Center(child: button);
  }
}
