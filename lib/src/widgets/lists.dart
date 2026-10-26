import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';
import 'pressable.dart';
import 'text_widgets.dart';

/// One row of a [UiOptionGroup].
@immutable
class UiOption {
  const UiOption(
    this.label, {
    required this.onTap,
    this.icon,
    this.leading,
    this.detail,
    this.selected = false,
    this.danger = false,
    this.trailing,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  /// Replaces [icon] with an arbitrary leading widget (avatar, thumbnail...).
  final Widget? leading;

  /// Secondary line under the label.
  final String? detail;

  /// Highlights the row and shows a check mark.
  final bool selected;

  /// Renders the row in the danger color ("Delete").
  final bool danger;
  final Widget? trailing;
}

/// Rounded block of tappable rows separated by hairlines: the content of
/// action sheets, pickers and menus. Set [scroll] for long lists.
class UiOptionGroup extends StatelessWidget {
  const UiOptionGroup(this.items, {super.key, this.scroll = false});

  final List<UiOption> items;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final divider = Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: ui.colors.border,
    );
    final Widget body = scroll
        ? ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => divider,
            itemBuilder: (_, i) => _OptionRow(items[i]),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) divider,
                _OptionRow(items[i]),
              ],
            ],
          );
    return ClipRRect(
      borderRadius: ui.shape.groupRadius,
      child: ColoredBox(color: ui.colors.surfaceAlt, child: body),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow(this.o);

  final UiOption o;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    final tone = o.danger ? c.danger : (o.selected ? c.primary : c.text);
    return Semantics(
      selected: o.selected,
      child: UiPressable(
        onTap: o.onTap,
        scale: 0.99,
        focusRadius: BorderRadius.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: o.detail == null ? 0 : 11,
            ),
            child: Row(
              children: [
                if (o.leading != null) ...[
                  o.leading!,
                  const SizedBox(width: 12),
                ] else if (o.icon != null) ...[
                  Icon(
                    o.icon,
                    size: 19,
                    color: o.danger
                        ? c.danger
                        : (o.selected ? c.primary : c.textSecondary),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.label,
                        style: ui.typography.strong(
                          14.5,
                          weight: o.selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: tone,
                        ),
                      ),
                      if (o.detail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          o.detail!,
                          style: ui.typography.strong(
                            12,
                            weight: FontWeight.w500,
                            color: c.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (o.selected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_circle_rounded, size: 18, color: c.primary),
                ],
                if (o.trailing != null) ...[
                  const SizedBox(width: 6),
                  o.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A label on the left and any control (switch, stepper, value) on the right.
/// Use it alone (rounded card) or inside a [UiListGroup].
class UiListRow extends StatelessWidget {
  const UiListRow({super.key, required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return ClipRRect(
      borderRadius: ui.shape.cardRadius,
      child: ColoredBox(color: ui.colors.surface, child: _line(context)),
    );
  }

  Widget _line(BuildContext context) {
    final ui = context.ui;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: ui.typography.strong(
                  14.5,
                  weight: FontWeight.w500,
                  color: ui.colors.text,
                ),
              ),
            ),
            const SizedBox(width: 12),
            control,
          ],
        ),
      ),
    );
  }
}

/// Stacks [UiListRow]s in one rounded card with hairline dividers (settings).
class UiListGroup extends StatelessWidget {
  const UiListGroup(this.rows, {super.key});

  final List<UiListRow> rows;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return ClipRRect(
      borderRadius: ui.shape.cardRadius,
      child: ColoredBox(
        color: ui.colors.surface,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: ui.colors.border,
                ),
              rows[i]._line(context),
            ],
          ],
        ),
      ),
    );
  }
}

/// `–  value  +` control with rolling digits.
class UiStepper extends StatelessWidget {
  const UiStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.onTapValue,
    this.minWidth = 70,
    this.buttonSize = 30,
    this.gap = 14,
    this.fontSize = 16,
  });

  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback? onTapValue;
  final double minWidth;
  final double buttonSize;
  final double gap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    Widget btn(IconData icon, String label, VoidCallback? onTap) => UiPressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: label,
      focusRadius: ui.shape.smallRadius,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.4 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: ui.colors.surfaceAlt,
            borderRadius: ui.shape.smallRadius,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: fontSize + 2, color: ui.colors.text),
        ),
      ),
    );
    Widget label = Container(
      constraints: BoxConstraints(minWidth: minWidth),
      alignment: Alignment.center,
      child: UiRollingText(
        value,
        style: ui.typography.strong(fontSize, color: ui.colors.text),
      ),
    );
    if (onTapValue != null) {
      label = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapValue,
        child: label,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove_rounded, 'Decrease', onDecrement),
        SizedBox(width: gap),
        label,
        SizedBox(width: gap),
        btn(Icons.add_rounded, 'Increase', onIncrement),
      ],
    );
  }
}
