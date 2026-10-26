import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// Corner radii. The look is "pills and soft cards": controls are fully
/// rounded ([pill]), containers use 18-28 logical pixels.
@immutable
class UiShape {
  const UiShape({
    this.small = 8,
    this.field = 16,
    this.group = 18,
    this.card = 20,
    this.dialog = 26,
    this.sheet = 28,
    this.nav = 28,
    this.pill = 100,
  });

  final double small;
  final double field;
  final double group;
  final double card;
  final double dialog;
  final double sheet;
  final double nav;
  final double pill;

  BorderRadius get smallRadius => BorderRadius.circular(small);
  BorderRadius get fieldRadius => BorderRadius.circular(field);
  BorderRadius get groupRadius => BorderRadius.circular(group);
  BorderRadius get cardRadius => BorderRadius.circular(card);
  BorderRadius get dialogRadius => BorderRadius.circular(dialog);
  BorderRadius get sheetRadius => BorderRadius.circular(sheet);
  BorderRadius get navRadius => BorderRadius.circular(nav);
  BorderRadius get pillRadius => BorderRadius.circular(pill);

  UiShape copyWith({
    double? small,
    double? field,
    double? group,
    double? card,
    double? dialog,
    double? sheet,
    double? nav,
    double? pill,
  }) => UiShape(
    small: small ?? this.small,
    field: field ?? this.field,
    group: group ?? this.group,
    card: card ?? this.card,
    dialog: dialog ?? this.dialog,
    sheet: sheet ?? this.sheet,
    nav: nav ?? this.nav,
    pill: pill ?? this.pill,
  );

  static UiShape lerp(UiShape a, UiShape b, double t) => UiShape(
    small: lerpDouble(a.small, b.small, t)!,
    field: lerpDouble(a.field, b.field, t)!,
    group: lerpDouble(a.group, b.group, t)!,
    card: lerpDouble(a.card, b.card, t)!,
    dialog: lerpDouble(a.dialog, b.dialog, t)!,
    sheet: lerpDouble(a.sheet, b.sheet, t)!,
    nav: lerpDouble(a.nav, b.nav, t)!,
    pill: lerpDouble(a.pill, b.pill, t)!,
  );
}
