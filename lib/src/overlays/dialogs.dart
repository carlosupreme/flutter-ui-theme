import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';
import 'glass_routes.dart';

/// Themed [AlertDialog] with the package's rounded, roomy layout. Use it inside
/// [showUiDialog]; [showUiConfirm] already does.
AlertDialog uiAlertDialog(
  BuildContext context, {
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  final ui = context.ui;
  return AlertDialog(
    backgroundColor: ui.colors.surface,
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
    contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    shape: RoundedRectangleBorder(borderRadius: ui.shape.dialogRadius),
    title: title,
    content: content,
    actions: actions,
  );
}

/// Pill-shaped text action for [uiAlertDialog].
Widget uiDialogAction(
  BuildContext context,
  String label,
  VoidCallback onPressed, {
  Color? color,
  bool strong = true,
}) {
  final ui = context.ui;
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: ui.shape.pillRadius),
    ),
    child: Text(
      label,
      style: ui.typography.strong(
        14,
        weight: strong ? FontWeight.w700 : FontWeight.w600,
        color: color ?? (strong ? ui.colors.accent : ui.colors.textSecondary),
      ),
    ),
  );
}

/// Two-button confirmation. Resolves to `true` only if the user confirmed;
/// dismissing the dialog counts as `false`. [danger] colors the confirm action
/// red (for deletions).
Future<bool> showUiConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
  bool danger = false,
}) async {
  final ui = context.ui;
  final ok = await showUiDialog<bool>(
    context: context,
    builder: (dctx) => uiAlertDialog(
      dctx,
      title: Text(
        title,
        style: ui.typography.strong(
          19,
          weight: FontWeight.w800,
          color: ui.colors.text,
        ),
      ),
      content: Text(
        body,
        style: ui.typography.strong(
          13.5,
          weight: FontWeight.w500,
          color: ui.colors.textSecondary,
          height: 1.45,
        ),
      ),
      actions: [
        uiDialogAction(
          dctx,
          cancelLabel ?? MaterialLocalizations.of(dctx).cancelButtonLabel,
          () => Navigator.of(dctx).pop(false),
          strong: false,
        ),
        uiDialogAction(
          dctx,
          confirmLabel,
          () => Navigator.of(dctx).pop(true),
          color: danger ? ui.colors.danger : ui.colors.accent,
        ),
      ],
    ),
  );
  return ok ?? false;
}
