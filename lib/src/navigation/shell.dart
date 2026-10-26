import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../overlays/edge_blur.dart';
import '../tokens/ui_theme.dart';
import 'nav_bar.dart';
import 'nav_rail.dart';

/// Width at which [UiShell] switches from a bottom bar to a side rail.
const double kUiShellRailBreakpoint = 840;

/// Width at which the side rail shows full labels.
const double kUiShellExtendedBreakpoint = 1280;

/// Adaptive app frame. On narrow windows (phones) it floats a [UiNavBar] over
/// the bottom of [body] with a progressive blur beneath it; on wide windows
/// (macOS, Windows, tablets) it shows a [UiNavRail] on the left instead.
///
/// [body] receives the right `MediaQuery.padding.bottom` so scroll views leave
/// room for the floating bar without any extra work. Combine it with
/// `UiScreenSwitcher` to animate between tabs:
///
/// ```dart
/// UiShell(
///   items: items,
///   selectedIndex: tab,
///   onSelected: (i) => setState(() => tab = i),
///   body: UiScreenSwitcher(screenKey: tab, index: tab, child: pages[tab]),
/// )
/// ```
class UiShell extends StatelessWidget {
  const UiShell({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.action,
    this.actionIndex,
    this.railLeading,
    this.railTrailing,
    this.railBreakpoint = kUiShellRailBreakpoint,
    this.extendedBreakpoint = kUiShellExtendedBreakpoint,
    this.blurEdges = true,
  });

  final List<UiNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;
  final UiNavAction? action;
  final int? actionIndex;

  /// Widgets placed at the top/bottom of the side rail (wide layout only).
  final Widget? railLeading;
  final Widget? railTrailing;

  final double railBreakpoint;
  final double extendedBreakpoint;

  /// Fade content under the floating bar with a progressive blur.
  final bool blurEdges;

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= railBreakpoint) {
          return ColoredBox(
            color: ui.colors.background,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: UiNavRail(
                    items: items,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                    action: action,
                    extended: box.maxWidth >= extendedBreakpoint,
                    leading: railLeading,
                    trailing: railTrailing,
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        final media = MediaQuery.of(context);
        final keyboardOpen = media.viewInsets.bottom > 60;
        final bottom = media.viewPadding.bottom;
        final reserved = keyboardOpen
            ? 0.0
            : 18 + UiNavBar.height + 10 + bottom;
        return Stack(
          children: [
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(
                    bottom: math.max(media.padding.bottom, reserved),
                  ),
                ),
                child: body,
              ),
            ),
            if (!keyboardOpen) ...[
              if (blurEdges)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: UiEdgeBlur(top: false, height: 128 + bottom),
                ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18 + bottom,
                child: RepaintBoundary(
                  child: UiNavBar(
                    items: items,
                    selectedIndex: selectedIndex,
                    onSelected: onSelected,
                    action: action,
                    actionIndex: actionIndex,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
