import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';
import 'pressable.dart';

/// Full-width, fully rounded, high-emphasis button (the "Save", "Book",
/// "Continue" button). Set [expand] to false for a content-sized one.
///
/// `onPressed == null` renders the disabled state; [loading] swaps the icon for
/// a spinner and blocks taps.
class UiPrimaryButton extends StatelessWidget {
  const UiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.background,
    this.foreground,
    this.height = 56,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final double height;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final fg = foreground ?? ui.colors.onPrimary;
    final enabled = onPressed != null && !loading;
    return UiPressable(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: onPressed == null && !loading ? 0.45 : 1,
        duration: const Duration(milliseconds: 160),
        child: Container(
          width: expand ? double.infinity : null,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: expand ? 16 : 28),
          decoration: BoxDecoration(
            color: background ?? ui.colors.primary,
            borderRadius: ui.shape.pillRadius,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                ),
                const SizedBox(width: 10),
              ] else if (icon != null) ...[
                Icon(icon, size: 17, color: fg),
                const SizedBox(width: 9),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: ui.typography.strong(
                      15.5,
                      color: fg,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiet pill button on [UiColors.surfaceAlt]: secondary actions such as
/// "Cancel", "Add note" or "Export".
class UiSecondaryButton extends StatelessWidget {
  const UiSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return UiPressable(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.45 : 1,
        duration: const Duration(milliseconds: 160),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ui.colors.surfaceAlt,
            borderRadius: ui.shape.pillRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: ui.colors.primary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: ui.typography.strong(13.5, color: ui.colors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded chip-button. With [selected] it flips to the primary fill, so
/// a row of them works as a single-choice filter. Pass [background] and
/// [foreground] to color it manually (for example a status pill).
class UiPill extends StatelessWidget {
  const UiPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.background,
    this.foreground,
    this.icon,
    this.hPad = 14,
    this.vPad = 8,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? background;
  final Color? foreground;
  final IconData? icon;
  final double hPad;
  final double vPad;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final bg =
        background ?? (selected ? ui.colors.primary : ui.colors.surfaceAlt);
    final fg = foreground ?? (selected ? ui.colors.onPrimary : ui.colors.text);
    return UiPressable(
      onTap: onPressed,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(color: bg, borderRadius: ui.shape.pillRadius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: ui.typography.strong(
                fontSize,
                weight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon button (back, close, add). [filled] uses the primary color.
/// Give it a [semanticLabel]: it has no visible text.
class UiRoundButton extends StatelessWidget {
  const UiRoundButton({
    super.key,
    this.icon,
    this.child,
    required this.onPressed,
    this.semanticLabel,
    this.size = 36,
    this.filled = false,
  }) : assert(icon != null || child != null, 'Provide an icon or a child');

  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final fg = filled ? ui.colors.onPrimary : ui.colors.text;
    return UiPressable(
      onTap: onPressed,
      scale: 0.9,
      semanticLabel: semanticLabel,
      focusRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: filled ? ui.colors.primary : ui.colors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled ? ui.colors.primary : ui.colors.border,
          ),
        ),
        child: Center(
          child: child ?? Icon(icon, size: size * 0.47, color: fg),
        ),
      ),
    );
  }
}

/// One option of a [UiSegmentedToggle].
@immutable
class UiSegment<T> {
  const UiSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// Pill-shaped single-choice switch ("Day | Week | Month").
class UiSegmentedToggle<T> extends StatelessWidget {
  const UiSegmentedToggle({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.hPad = 14,
    this.vPad = 7,
    this.fontSize = 12,
  });

  final List<UiSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final double hPad;
  final double vPad;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ui.colors.surfaceAlt,
        borderRadius: ui.shape.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in segments)
            Semantics(
              selected: s.value == value,
              child: UiPressable(
                onTap: () => onChanged(s.value),
                scale: 0.96,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: hPad,
                    vertical: vPad,
                  ),
                  decoration: BoxDecoration(
                    color: s.value == value
                        ? ui.colors.primary
                        : Colors.transparent,
                    borderRadius: ui.shape.pillRadius,
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: ui.typography.strong(
                      fontSize,
                      weight: FontWeight.w600,
                      color: s.value == value
                          ? ui.colors.onPrimary
                          : ui.colors.textSecondary,
                    ),
                    child: Text(s.label),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Compact animated on/off switch.
class UiSwitch extends StatelessWidget {
  const UiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: UiPressable(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        scale: 0.94,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 44,
          height: 26,
          padding: const EdgeInsets.all(3),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? c.primary : c.surfaceAlt,
            borderRadius: ui.shape.pillRadius,
            border: Border.all(color: value ? c.primary : c.border),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? c.onPrimary : c.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
