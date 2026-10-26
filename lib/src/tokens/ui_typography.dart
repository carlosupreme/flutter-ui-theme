import 'package:flutter/widgets.dart';

/// Font family plus the three style builders the original design is made of.
///
/// The bundled font is Nunito (SIL OFL). To use your own font, declare it in
/// your app's pubspec and pass `UiTypography(family: 'Inter', package: null)`.
@immutable
class UiTypography {
  const UiTypography({
    this.family = 'Nunito',
    this.package = 'flutter_ui_theme',
  });

  final String family;

  /// Package that owns [family]; `null` when the font lives in the app itself.
  final String? package;

  /// Bold, tight line height: titles, buttons, labels. (w700, height 1.15)
  TextStyle strong(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double height = 1.15,
  }) => _style(size, weight, color, letterSpacing, height);

  /// Regular weight with generous line height: paragraphs. (w400, height 1.35)
  TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double height = 1.35,
  }) => _style(size, weight, color, letterSpacing, height);

  /// Big numerals and display text with no extra leading. (w700, height 1.0)
  TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double height = 1.0,
  }) => _style(size, weight, color, letterSpacing, height);

  TextStyle _style(
    double size,
    FontWeight weight,
    Color? color,
    double? letterSpacing,
    double height,
  ) => TextStyle(
    fontFamily: family,
    package: package,
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  UiTypography copyWith({String? family, String? package}) => UiTypography(
    family: family ?? this.family,
    package: package ?? this.package,
  );
}
