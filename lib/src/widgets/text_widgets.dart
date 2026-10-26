import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

final _digitCells = <(TextStyle, double), double>{};

/// Width of the widest digit for [style], so digits roll in fixed-width cells
/// and the number does not jitter.
double uiDigitCell(TextStyle style, TextScaler scaler) {
  if (_digitCells.length > 48) _digitCells.clear();
  return _digitCells.putIfAbsent((style, scaler.scale(100)), () {
    var widest = 0.0;
    for (var d = 0; d < 10; d++) {
      final p = TextPainter(
        text: TextSpan(text: '$d', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      if (p.width > widest) widest = p.width;
      p.dispose();
    }
    return widest.ceilToDouble();
  });
}

/// Text whose characters roll up or down when the value changes, like an
/// odometer. Use it for counters and live metrics. Direction follows the
/// numeric change unless [countsDown] forces it.
class UiRollingText extends StatefulWidget {
  const UiRollingText(
    this.text, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 420),
    this.countsDown,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final TextStyle style;
  final Duration duration;
  final bool? countsDown;
  final TextAlign textAlign;

  @override
  State<UiRollingText> createState() => _UiRollingTextState();
}

class _UiRollingTextState extends State<UiRollingText> {
  static const _burst = Duration(milliseconds: 180);

  bool _up = true;
  bool _rapid = false;
  DateTime? _changedAt;

  static double? _numeric(String s) {
    final digits = s
        .replaceAll(RegExp(r'[,٫]'), '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return digits.isEmpty ? null : double.tryParse(digits);
  }

  @override
  void didUpdateWidget(UiRollingText old) {
    super.didUpdateWidget(old);
    if (old.text == widget.text) return;
    final now = DateTime.now();
    _rapid = _changedAt != null && now.difference(_changedAt!) < _burst;
    _changedAt = now;
    final forced = widget.countsDown;
    if (forced != null) {
      _up = !forced;
      return;
    }
    final a = _numeric(old.text), b = _numeric(widget.text);
    if (a != null && b != null && a != b) _up = b > a;
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    final n = chars.length;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final scaler = MediaQuery.textScalerOf(context);
    final line =
        scaler.scale(widget.style.fontSize ?? 14) *
        (widget.style.height ?? 1.2);
    final digit = uiDigitCell(widget.style, scaler);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < n; i++)
          _RollingChar(
            key: ValueKey(n - i),
            char: chars[i],
            style: widget.style,
            up: _up,
            duration: reduce || _rapid ? Duration.zero : widget.duration,
            solo: _rapid,
            line: line,
            width: _isDigit(chars[i]) ? digit : null,
          ),
      ],
    );
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedSize(
        duration: reduce || _rapid
            ? const Duration(milliseconds: 1)
            : const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: switch (widget.textAlign) {
          TextAlign.right || TextAlign.end => Alignment.centerRight,
          TextAlign.center => Alignment.center,
          _ => Alignment.centerLeft,
        },
        child: row,
      ),
    );
  }

  static bool _isDigit(String c) =>
      c.length == 1 && c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

/// Clips a rolling character to its line box so the outgoing glyph is hidden.
///
/// Digits have no descenders, so they clip tightly. Punctuation and letters
/// (the comma in "1,248", a "g") hang below the baseline and get extra room.
class _RollClipper extends CustomClipper<Rect> {
  const _RollClipper(this.line, {required this.loose});

  final double line;
  final bool loose;

  @override
  Rect getClip(Size size) => loose
      ? Rect.fromLTRB(
          -2,
          -line * 0.25,
          size.width + 2,
          size.height + line * 0.55,
        )
      : Rect.fromLTRB(-2, 0, size.width + 2, size.height);

  @override
  bool shouldReclip(_RollClipper old) => old.line != line || old.loose != loose;
}

class _RollingChar extends StatelessWidget {
  const _RollingChar({
    super.key,
    required this.char,
    required this.style,
    required this.up,
    required this.duration,
    required this.line,
    this.solo = false,
    this.width,
  });

  final String char;
  final TextStyle style;
  final bool up;
  final Duration duration;
  final double line;
  final bool solo;
  final double? width;

  static const _tight = TextHeightBehavior(
    applyHeightToFirstAscent: false,
    applyHeightToLastDescent: false,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: _RollClipper(line, loose: width == null),
      child: SizedBox(
        height: line,
        width: width,
        child: AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [if (!solo) ...previous, ?current],
          ),
          transitionBuilder: (child, animation) {
            final incoming = (child.key as ValueKey?)?.value == char;
            final from = incoming ? (up ? 0.72 : -0.72) : (up ? -0.72 : 0.72);
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (_, kid) {
                final t = animation.value;
                return Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, from * line * (1 - t)),
                    child: kid,
                  ),
                );
              },
            );
          },
          child: Text(
            char,
            key: ValueKey(char),
            style: style,
            textHeightBehavior: _tight,
          ),
        ),
      ),
    );
  }
}

/// Single-line text that scrolls horizontally when it does not fit (tap to
/// pause). Falls back to an ellipsis for users who disabled animations.
class UiMarqueeText extends StatefulWidget {
  const UiMarqueeText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<UiMarqueeText> createState() => _UiMarqueeTextState();
}

class _UiMarqueeTextState extends State<UiMarqueeText>
    with SingleTickerProviderStateMixin {
  static const _gap = 48.0;
  static const _speed = 38.0;
  static const _holdMs = 1600;

  late final AnimationController _c;
  double _run = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this);
  }

  int get _scrollMs => (_run / _speed * 1000).round();

  void _sync(double run, bool still) {
    if (run == _run) return;
    _run = run;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _run != run) return;
      if (run == 0) {
        _c.stop();
        _c.value = 0;
        return;
      }
      _c.duration = Duration(milliseconds: _holdMs + _scrollMs);
      _c.value = 0;
      if (!_paused && !still) _c.repeat();
    });
  }

  void _toggle() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _c.stop();
    } else {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style =
        widget.style ??
        context.ui.typography.strong(
          20,
          weight: FontWeight.w800,
          color: context.ui.colors.text,
        );
    return LayoutBuilder(
      builder: (context, box) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final fits = tp.width <= box.maxWidth;
        final textHeight = tp.height;
        final textWidth = tp.width;
        tp.dispose();
        _sync(
          fits ? 0 : textWidth + _gap,
          MediaQuery.disableAnimationsOf(context),
        );
        final plain = Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
        if (fits) return plain;
        final rtl = Directionality.of(context) == TextDirection.rtl;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggle,
          child: Semantics(
            label: widget.text,
            excludeSemantics: true,
            child: SizedBox(
              width: box.maxWidth,
              height: textHeight,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, child) {
                    final total = _holdMs + _scrollMs;
                    final ms = _c.value * total;
                    final dx = ms <= _holdMs
                        ? 0.0
                        : (ms - _holdMs) / _scrollMs * _run;
                    return Transform.translate(
                      offset: Offset(rtl ? dx : -dx, 0),
                      child: child,
                    );
                  },
                  child: OverflowBox(
                    alignment: rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.text,
                          maxLines: 1,
                          softWrap: false,
                          style: style,
                        ),
                        const SizedBox(width: _gap),
                        Text(
                          widget.text,
                          maxLines: 1,
                          softWrap: false,
                          style: style,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
