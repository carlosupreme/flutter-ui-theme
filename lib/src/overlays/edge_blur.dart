import 'dart:ui' as ui_;

import 'package:flutter/material.dart';

import '../tokens/ui_theme.dart';

/// Progressive blur that fades content out toward a screen edge, so scrolling
/// lists dissolve under the status bar or the floating nav bar instead of being
/// cut off. Place it in a `Stack` above the content (it ignores pointers).
///
/// Uses a fragment shader where supported and falls back to stacked blur strips
/// elsewhere (the output is nearly identical).
class UiEdgeBlur extends StatefulWidget {
  const UiEdgeBlur({
    super.key,
    required this.height,
    this.top = true,
    this.sigma = 16,
    this.shade = 1,
    this.color,
  });

  final double height;

  /// true: fades toward the top edge; false: toward the bottom edge.
  final bool top;
  final double sigma;

  /// Strength (0..1) of the background-colored gradient laid over the blur.
  final double shade;

  /// Gradient color. Defaults to `UiColors.background`; set it to the color the
  /// content scrolls over.
  final Color? color;

  @override
  State<UiEdgeBlur> createState() => _UiEdgeBlurState();
}

class _UiEdgeBlurState extends State<UiEdgeBlur> {
  static const _asset = 'packages/flutter_ui_theme/shaders/edge_fade.frag';
  static Future<ui_.FragmentProgram>? _loading;
  static ui_.FragmentProgram? _program;

  final _shaders = <ui_.FragmentShader>[];
  List<ui_.ImageFilter>? _filters;
  Object? _filtersFor;

  @override
  void initState() {
    super.initState();
    if (_program != null || !ui_.ImageFilter.isShaderFilterSupported) return;
    (_loading ??= ui_.FragmentProgram.fromAsset(_asset)).then((p) {
      _program = p;
      if (mounted) setState(() {});
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _dropShaders();
    super.dispose();
  }

  void _dropShaders() {
    for (final s in _shaders) {
      s.dispose();
    }
    _shaders.clear();
  }

  List<ui_.ImageFilter> _layers(ui_.FragmentProgram program, double dpr) {
    final key = (widget.height, widget.top, widget.sigma, dpr);
    if (_filters != null && _filtersFor == key) return _filters!;
    _dropShaders();
    ui_.ImageFilter layer(double sigma, double from, double to) {
      final shader = program.fragmentShader()
        ..setFloat(2, widget.height * dpr)
        ..setFloat(3, from)
        ..setFloat(4, to)
        ..setFloat(5, widget.top ? 1 : 0);
      _shaders.add(shader);
      return ui_.ImageFilter.compose(
        outer: ui_.ImageFilter.shader(shader),
        inner: ui_.ImageFilter.blur(
          sigmaX: sigma,
          sigmaY: sigma,
          tileMode: TileMode.clamp,
        ),
      );
    }

    _filtersFor = key;
    return _filters = [
      layer(widget.sigma * 0.35, 0.2, 1),
      layer(widget.sigma, 0.08, 0.66),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? context.ui.colors.background;
    final program = _program;
    return IgnorePointer(
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            if (program != null)
              for (final f in _layers(
                program,
                MediaQuery.devicePixelRatioOf(context),
              ))
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter.grouped(
                      filter: f,
                      child: const SizedBox.expand(),
                    ),
                  ),
                )
            else
              ..._strips(),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: widget.top
                        ? Alignment.topCenter
                        : Alignment.bottomCenter,
                    end: widget.top
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    colors: [
                      for (final a in const [0.82, 0.62, 0.38, 0.17, 0.05, 0.0])
                        base.withValues(alpha: a * widget.shade),
                    ],
                    stops: const [0, 0.2, 0.42, 0.64, 0.84, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _strips() {
    const n = 6;
    final strip = widget.height * 0.8 / n;
    return [
      for (var i = 0; i < n; i++)
        Positioned(
          left: 0,
          right: 0,
          top: widget.top ? strip * i : widget.height - strip * (i + 1),
          height: strip + 0.5,
          child: ClipRect(
            child: BackdropFilter.grouped(
              filter: ui_.ImageFilter.blur(
                sigmaX: widget.sigma * (1 - i / n) * 0.7,
                sigmaY: widget.sigma * (1 - i / n) * 0.7,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
    ];
  }
}
