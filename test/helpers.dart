import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

/// Pumps [child] inside a themed MaterialApp + Scaffold.
Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  UiTheme ui = UiTheme.light,
  Size size = const Size(420, 900),
  bool center = true,
  bool disableAnimations = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildUiTheme(ui),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: c!,
      ),
      home: Scaffold(body: center ? Center(child: child) : child),
    ),
  );
}

const navItems = [
  UiNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  UiNavItem(
    icon: Icons.people_outline,
    activeIcon: Icons.people_rounded,
    label: 'Patients',
  ),
  UiNavItem(
    icon: Icons.event_outlined,
    activeIcon: Icons.event_rounded,
    label: 'Calendar',
    badge: 3,
  ),
  UiNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];
