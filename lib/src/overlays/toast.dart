import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui_;

import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

enum UiToastPosition { top, bottom }

final _sessions = Expando<_ToastSession>('ui toasts');

/// Pill-shaped notification that blurs and springs in from the top (or
/// bottom) edge, then dismisses itself. Works on phones and desktop windows.
///
/// A new toast replaces the one on screen. The returned future completes when
/// the toast is gone. Tapping it dismisses it and calls [onTap].
///
/// Pass [accent] to color the icon and the [actionLabel]; it defaults to
/// `UiColors.success`.
Future<void> showUiToast(
  BuildContext context,
  String title, {
  String? subtitle,
  IconData? icon = Icons.check_rounded,
  Color? accent,
  String? actionLabel,
  VoidCallback? onTap,
  Duration? duration,
  UiToastPosition position = UiToastPosition.top,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return Future.value();
  final ui = context.ui;
  final words = '$title ${subtitle ?? ''}'.trim().split(RegExp(r'\s+')).length;
  final request = _ToastRequest(
    title: title,
    subtitle: subtitle,
    icon: icon,
    accent: accent ?? ui.colors.success,
    actionLabel: actionLabel,
    onTap: onTap,
    duration:
        duration ?? Duration(milliseconds: math.max(2200, 900 + words * 330)),
    position: position,
    themes: InheritedTheme.capture(from: context, to: overlay.context),
    ui: ui,
  );
  (_sessions[overlay] ??= _ToastSession(overlay)).show(request);
  return request.done.future;
}

class _ToastRequest {
  _ToastRequest({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.actionLabel,
    required this.onTap,
    required this.duration,
    required this.position,
    required this.themes,
    required this.ui,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color accent;
  final String? actionLabel;
  final VoidCallback? onTap;
  final Duration duration;
  final UiToastPosition position;
  final CapturedThemes themes;
  final UiTheme ui;
  final done = Completer<void>();

  void complete() {
    if (!done.isCompleted) done.complete();
  }
}

class _ToastSession {
  _ToastSession(this.overlay);

  final OverlayState overlay;
  OverlayEntry? _entry;
  _ToastRequest? _active;

  void show(_ToastRequest request) {
    _remove();
    _active = request;
    _entry = OverlayEntry(
      builder: (_) =>
          _ToastHost(request: request, onFinished: () => _finished(request)),
    );
    overlay.insert(_entry!);
  }

  void _finished(_ToastRequest request) {
    if (!identical(_active, request)) return;
    _remove();
  }

  void _remove() {
    final entry = _entry;
    final active = _active;
    _entry = null;
    _active = null;
    if (entry != null) {
      // Removing is safe here (called from event handlers and async gaps, never
      // during build); disposal waits until the entry has unmounted.
      entry.remove();
      WidgetsBinding.instance.addPostFrameCallback((_) => entry.dispose());
    }
    active?.complete();
  }
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({required this.request, required this.onFinished});

  final _ToastRequest request;
  final VoidCallback onFinished;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration:
        widget.request.ui.motion.overlay + const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 240),
  );
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.request.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    await _c.reverse();
    widget.onFinished();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final ui = r.ui;
    final top = r.position == UiToastPosition.top;
    final media = MediaQuery.of(context);
    final reduce = media.disableAnimations;
    final pad = media.viewPadding;

    final pill = _ToastPill(
      request: r,
      onTap: () {
        unawaited(_dismiss());
        r.onTap?.call();
      },
    );

    return Positioned.fill(
      child: r.themes.wrap(
        IgnorePointer(
          ignoring: _leaving,
          child: Align(
            alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                (top ? pad.top : 0) + 14,
                16,
                (top ? 0 : pad.bottom) + 14,
              ),
              child: AnimatedBuilder(
                animation: _c,
                child: pill,
                builder: (context, child) {
                  final t = Curves.easeOutCubic.transform(_c.value);
                  final settle = _c.status == AnimationStatus.reverse
                      ? t
                      : Curves.easeOutBack.transform(_c.value);
                  if (reduce) return Opacity(opacity: t, child: child);
                  final blur = (1 - t) * 3;
                  return Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, (top ? -26 : 26) * (1 - settle)),
                      child: Transform.scale(
                        scale:
                            ui.motion.dialogScaleFrom +
                            (1 - ui.motion.dialogScaleFrom) * settle,
                        child: ImageFiltered(
                          enabled: blur > 0.05,
                          imageFilter: ui_.ImageFilter.blur(
                            sigmaX: blur,
                            sigmaY: blur,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastPill extends StatelessWidget {
  const _ToastPill({required this.request, required this.onTap});

  final _ToastRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ui = request.ui;
    final r = request;
    return Semantics(
      liveRegion: true,
      container: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, minHeight: 53),
            child: Material(
              type: MaterialType.transparency,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ui.effects.toastBackground,
                  borderRadius: BorderRadius.circular(
                    r.subtitle == null ? 28 : 26,
                  ),
                  boxShadow: [ui.effects.navShadow],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 0.8,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 16, 9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (r.icon != null) ...[
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: r.accent.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(r.icon, size: 18, color: r.accent),
                        ),
                        const SizedBox(width: 11),
                      ] else
                        const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ui.typography.strong(
                                14,
                                weight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            if (r.subtitle != null &&
                                r.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                r.subtitle!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: ui.typography.strong(
                                  11.5,
                                  weight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (r.actionLabel != null) ...[
                        const SizedBox(width: 14),
                        Text(
                          r.actionLabel!,
                          style: ui.typography.strong(
                            13,
                            weight: FontWeight.w800,
                            color: r.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
