import 'package:flutter/material.dart';

import '../transitions/page_transitions.dart';
import 'ui_theme.dart';

/// Builds a complete Material 3 [ThemeData] from [ui]: stock buttons, inputs,
/// dialogs, pickers, switches, menus, scrollbars and page transitions all take
/// the new look, so existing screens change without being rewritten.
///
/// The returned theme carries [ui] as an extension, which is what `context.ui`
/// and every widget in this package read.
ThemeData buildUiTheme(UiTheme ui) {
  final c = ui.colors;
  final t = ui.typography;
  final shape = ui.shape;
  final brightness = ui.isDark ? Brightness.dark : Brightness.light;

  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    fontFamily: t.family,
    package: t.package,
  );

  final scheme = base.colorScheme.copyWith(
    primary: c.accent,
    onPrimary: c.onPrimary,
    secondary: c.primary,
    onSecondary: c.onPrimary,
    surface: c.surface,
    onSurface: c.text,
    onSurfaceVariant: c.textSecondary,
    surfaceContainerHighest: c.surfaceAlt,
    outline: c.border,
    outlineVariant: c.border,
    error: c.danger,
    onError: Colors.white,
  );

  const pill = StadiumBorder();
  final pillShape = WidgetStatePropertyAll<OutlinedBorder>(pill);
  WidgetStateProperty<Color?> selectedFill(Color selected, Color idle) =>
      WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? selected : idle,
      );

  // Time-picker fields are typed `Color?` and need a WidgetStateColor.
  WidgetStateColor selectedColor(Color selected, Color idle) =>
      WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.selected) ? selected : idle,
      );

  OutlineInputBorder field(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: shape.fieldRadius,
        borderSide: color == Colors.transparent
            ? BorderSide.none
            : BorderSide(color: color, width: width),
      );

  final dialogTitle = t.strong(19, weight: FontWeight.w800, color: c.text);
  final dialogBody = t.strong(
    13.5,
    weight: FontWeight.w500,
    color: c.textSecondary,
    height: 1.45,
  );

  return base
      .copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: c.background,
        canvasColor: c.background,
        textTheme: base.textTheme.apply(
          bodyColor: c.text,
          displayColor: c.text,
        ),
        primaryTextTheme: base.primaryTextTheme.apply(
          bodyColor: c.text,
          displayColor: c.text,
        ),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: c.text.withValues(alpha: 0.05),
        focusColor: c.text.withValues(alpha: 0.1),
        dividerColor: c.border,
        dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            for (final p in TargetPlatform.values)
              p: const UiPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: c.background,
          foregroundColor: c.text,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: t.strong(20, weight: FontWeight.w800, color: c.text),
        ),
        cardTheme: CardThemeData(
          color: c.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: shape.cardRadius,
            side: BorderSide(color: c.border),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: c.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: shape.dialogRadius),
          titleTextStyle: dialogTitle,
          contentTextStyle: dialogBody,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: c.surface,
          modalBackgroundColor: c.surface,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          showDragHandle: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(shape.sheet),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: c.primary,
            foregroundColor: c.onPrimary,
            disabledBackgroundColor: c.primary.withValues(alpha: 0.35),
            disabledForegroundColor: c.onPrimary.withValues(alpha: 0.6),
            minimumSize: const Size(64, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            shape: pill,
            textStyle: t.strong(15.5, letterSpacing: 0.2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: c.surfaceAlt,
            foregroundColor: c.text,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            minimumSize: const Size(64, 46),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: pill,
            textStyle: t.strong(13.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: c.text,
            minimumSize: const Size(64, 46),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            side: BorderSide(color: c.border),
            shape: pill,
            textStyle: t.strong(13.5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: c.accent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: pill,
            textStyle: t.strong(14),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: c.text),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: c.accent,
          foregroundColor: c.background,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: c.surface,
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          hintStyle: t.strong(
            14,
            weight: FontWeight.w500,
            color: c.textSecondary,
          ),
          labelStyle: t.strong(
            14,
            weight: FontWeight.w600,
            color: c.textSecondary,
          ),
          floatingLabelStyle: t.strong(
            12.5,
            weight: FontWeight.w700,
            color: c.accent,
          ),
          helperStyle: t.strong(
            12,
            weight: FontWeight.w500,
            color: c.textSecondary,
          ),
          errorStyle: t.strong(12, weight: FontWeight.w600, color: c.danger),
          prefixIconColor: c.textSecondary,
          suffixIconColor: c.textSecondary,
          border: field(c.border),
          enabledBorder: field(c.border),
          disabledBorder: field(Colors.transparent),
          focusedBorder: field(c.accent, 1.6),
          errorBorder: field(c.danger),
          focusedErrorBorder: field(c.danger, 1.6),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: c.accent,
          selectionColor: c.accent.withValues(alpha: 0.28),
          selectionHandleColor: c.accent,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: selectedFill(c.onPrimary, c.textTertiary),
          trackColor: selectedFill(c.primary, c.surfaceAlt),
          trackOutlineColor: selectedFill(c.primary, c.border),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? c.primary
                : Colors.transparent,
          ),
          checkColor: WidgetStatePropertyAll(c.onPrimary),
          side: BorderSide(color: c.textTertiary, width: 1.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        radioTheme: RadioThemeData(
          fillColor: selectedFill(c.primary, c.textTertiary),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: c.surfaceAlt,
          selectedColor: c.primary,
          disabledColor: c.muted,
          side: BorderSide.none,
          shape: pill,
          labelStyle: t.strong(13, weight: FontWeight.w600, color: c.text),
          secondaryLabelStyle: t.strong(
            13,
            weight: FontWeight.w600,
            color: c.onPrimary,
          ),
          checkmarkColor: c.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: c.primary,
          inactiveTrackColor: c.surfaceAlt,
          thumbColor: c.primary,
          overlayColor: c.primary.withValues(alpha: 0.12),
          trackHeight: 4,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: c.accent,
          linearTrackColor: c.surfaceAlt,
          circularTrackColor: c.surfaceAlt,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: c.textSecondary,
          textColor: c.text,
          titleTextStyle: t.strong(
            14.5,
            weight: FontWeight.w600,
            color: c.text,
          ),
          subtitleTextStyle: t.strong(
            12.5,
            weight: FontWeight.w500,
            color: c.textSecondary,
            height: 1.3,
          ),
          shape: RoundedRectangleBorder(borderRadius: shape.groupRadius),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: c.text,
          unselectedLabelColor: c.textTertiary,
          indicatorColor: c.accent,
          dividerColor: Colors.transparent,
          labelStyle: t.strong(14, weight: FontWeight.w800),
          unselectedLabelStyle: t.strong(14, weight: FontWeight.w600),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: c.surfaceAlt,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: shape.groupRadius),
          textStyle: t.strong(14.5, weight: FontWeight.w600, color: c.text),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(c.surfaceAlt),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: shape.groupRadius),
            ),
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: t.strong(14.5, weight: FontWeight.w600, color: c.text),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(c.surfaceAlt),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: shape.groupRadius),
            ),
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: shape.smallRadius,
            border: Border.all(color: c.border),
          ),
          textStyle: t.strong(12, weight: FontWeight.w600, color: c.text),
          waitDuration: const Duration(milliseconds: 500),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ui.effects.toastBackground,
          contentTextStyle: t.strong(
            14,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
          actionTextColor: c.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(c.text.withValues(alpha: 0.22)),
          radius: const Radius.circular(8),
          thickness: const WidgetStatePropertyAll(6),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: shape.sheetRadius),
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          hourMinuteColor: selectedColor(c.accentSoft, c.surfaceAlt),
          hourMinuteTextColor: selectedColor(c.accent, c.text),
          dayPeriodColor: selectedColor(c.accentSoft, Colors.transparent),
          dayPeriodTextColor: selectedColor(c.accent, c.textSecondary),
          dayPeriodBorderSide: BorderSide(color: c.border),
          helpTextStyle: t.strong(
            12,
            letterSpacing: 1.2,
            color: c.textSecondary,
          ),
          entryModeIconColor: c.textSecondary,
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: c.textSecondary,
          ),
          confirmButtonStyle: TextButton.styleFrom(foregroundColor: c.accent),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: c.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: shape.sheetRadius),
          headerBackgroundColor: c.surface,
          headerForegroundColor: c.text,
          dayForegroundColor: selectedFill(c.onPrimary, c.text),
          dayBackgroundColor: selectedFill(c.primary, Colors.transparent),
          todayForegroundColor: selectedFill(c.onPrimary, c.accent),
          todayBackgroundColor: selectedFill(c.primary, Colors.transparent),
          todayBorder: BorderSide(color: c.accent),
          yearForegroundColor: selectedFill(c.onPrimary, c.text),
          yearBackgroundColor: selectedFill(c.primary, Colors.transparent),
          rangeSelectionBackgroundColor: c.accentSoft,
          cancelButtonStyle: TextButton.styleFrom(
            foregroundColor: c.textSecondary,
          ),
          confirmButtonStyle: TextButton.styleFrom(foregroundColor: c.accent),
        ),
        extensions: [ui],
      )
      .copyWith(
        // Applied last so it is not overwritten by the defaults above.
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: pillShape,
            side: WidgetStatePropertyAll(BorderSide(color: c.border)),
            backgroundColor: selectedFill(c.primary, Colors.transparent),
            foregroundColor: selectedFill(c.onPrimary, c.textSecondary),
          ),
        ),
      );
}
