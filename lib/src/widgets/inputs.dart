import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';
import 'buttons.dart';
import 'text_widgets.dart';

/// Pill-shaped search box with a clear button that appears once there is text.
class UiSearchField extends StatelessWidget {
  const UiSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.icon = Icons.search_rounded,
    this.clearLabel,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Fill color. Defaults to `UiColors.surface`.
  final Color? color;
  final IconData icon;

  /// Screen-reader label of the clear button. Defaults to the platform's
  /// localized "Delete" tooltip.
  final String? clearLabel;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final c = ui.colors;
    return Container(
      height: 48,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 6),
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: ui.shape.pillRadius,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: ui.typography.strong(
                14,
                weight: FontWeight.w500,
                color: c.text,
              ),
              cursorColor: c.accent,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: ui.typography.strong(
                  14,
                  weight: FontWeight.w500,
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox(width: 10)
                : Semantics(
                    button: true,
                    label:
                        clearLabel ??
                        MaterialLocalizations.of(context).deleteButtonTooltip,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          controller.clear();
                          onChanged('');
                        },
                        child: SizedBox(
                          width: 40,
                          height: 48,
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: c.surfaceAlt,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Screen title row: round back button, marquee title, optional subtitle,
/// badge and trailing [actions]. Pass [onBack] null to hide the back button.
class UiScreenHeader extends StatelessWidget {
  const UiScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.subtitle,
    this.titleSize = 20,
    this.actions = const [],
    this.badge,
    this.backLabel,
  });

  final String title;
  final VoidCallback? onBack;
  final String? subtitle;
  final double titleSize;
  final List<Widget> actions;
  final Widget? badge;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    final titleStyle = ui.typography.strong(
      titleSize,
      weight: FontWeight.w800,
      color: ui.colors.text,
    );
    final titleWidget = UiMarqueeText(title, style: titleStyle);
    return Row(
      children: [
        if (onBack != null) ...[
          UiRoundButton(
            icon: Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            onPressed: onBack,
            semanticLabel:
                backLabel ??
                MaterialLocalizations.of(context).backButtonTooltip,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge == null)
                titleWidget
              else
                Row(
                  children: [
                    Flexible(child: titleWidget),
                    const SizedBox(width: 8),
                    badge!,
                  ],
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: ui.typography.strong(
                    12.5,
                    weight: FontWeight.w500,
                    color: ui.colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}
