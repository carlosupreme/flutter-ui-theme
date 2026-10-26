import 'package:flutter/material.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

enum Brand { original, clinic }

enum Mode { light, dark, amoled }

/// Shows how little code a rebrand takes: [Brand.clinic] is just a handful of
/// color overrides on top of the built-in palettes. Shape, motion, blur and
/// typography are untouched.
UiTheme paletteFor(Brand brand, Mode mode) {
  switch (brand) {
    case Brand.original:
      return switch (mode) {
        Mode.light => UiTheme.light,
        Mode.dark => UiTheme.dark,
        Mode.amoled => UiTheme.amoled,
      };
    case Brand.clinic:
      return switch (mode) {
        Mode.light => UiTheme.light.copyWith(colors: _clinicLight),
        Mode.dark => UiTheme.dark.copyWith(colors: _clinicDark),
        Mode.amoled => UiTheme.amoled.copyWith(
          colors: _clinicDark.copyWith(
            pageBackground: Colors.black,
            background: Colors.black,
            surface: const Color(0xFF0C1214),
            surfaceAlt: const Color(0xFF172124),
            navBackground: const Color(0xE6000000),
          ),
        ),
      };
  }
}

const _clinicLight = UiColors(
  pageBackground: Color(0xFFFBFDFD),
  background: Color(0xFFF1F6F6),
  surface: Color(0xFFFFFFFF),
  surfaceAlt: Color(0xFFE3EDED),
  border: Color(0xFFD3E1E1),
  navBackground: Color(0xF2FBFDFD),
  text: Color(0xFF0C2A30),
  textSecondary: Color(0xFF44606A),
  textTertiary: Color(0xFF4F6D77),
  primary: Color(0xFF0B6B7C),
  primaryDeep: Color(0xFF084F5C),
  onPrimary: Color(0xFFFFFFFF),
  primarySoft: Color(0x140B6B7C),
  primaryShadow: Color(0x330B6B7C),
  accent: Color(0xFF097676),
  accentAlt: Color(0xFF0A6F8F),
  accentSoft: Color(0x1F097676),
  success: Color(0xFF2B8A57),
  successSoft: Color(0x1F2B8A57),
  muted: Color(0xFFE3EDED),
  info: Color(0xFF2F6DB5),
  warning: Color(0xFF9A6A12),
  danger: Color(0xFFC0392B),
);

const _clinicDark = UiColors(
  pageBackground: Color(0xFF070D0F),
  background: Color(0xFF0A1214),
  surface: Color(0xFF121D20),
  surfaceAlt: Color(0xFF1C2A2E),
  border: Color(0xFF2B3E43),
  navBackground: Color(0xD90A1214),
  text: Color(0xFFF2FAFA),
  textSecondary: Color(0xFF9DB6BC),
  textTertiary: Color(0xFF7C979E),
  primary: Color(0xFF4FD1C5),
  primaryDeep: Color(0xFF38B2A8),
  onPrimary: Color(0xFF05201F),
  primarySoft: Color(0x1F4FD1C5),
  primaryShadow: Color(0x804FD1C5),
  accent: Color(0xFF4FD1C5),
  accentAlt: Color(0xFF3AA6C9),
  accentSoft: Color(0x294FD1C5),
  success: Color(0xFF6FCF97),
  successSoft: Color(0x296FCF97),
  muted: Color(0xFF1C2A2E),
  info: Color(0xFF7FB2E5),
  warning: Color(0xFFE5B85C),
  danger: Color(0xFFEF6F5E),
);
