import 'package:flutter/material.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'palettes.dart';
import 'pages.dart';

void main() => runApp(const GalleryApp());

/// Everything the user can change from the Theme tab. Rebuilding the
/// MaterialApp with a new [UiTheme] restyles the whole app, with animation.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  // Initial state can be set from the URL on web (?brand=clinic&mode=light&tab=2),
  // which makes screenshots and demos reproducible.
  final _query = Uri.base.queryParameters;
  late Brand brand =
      Brand.values.asNameMap()[_query['brand']] ?? Brand.original;
  late Mode mode = Mode.values.asNameMap()[_query['mode']] ?? Mode.dark;
  late int tab = (int.tryParse(_query['tab'] ?? '') ?? 0).clamp(0, 3);

  UiTheme get ui => paletteFor(brand, mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_ui_theme',
      debugShowCheckedModeBanner: false,
      theme: buildUiTheme(ui),
      home: GalleryHome(
        brand: brand,
        mode: mode,
        tab: tab,
        onBrand: (b) => setState(() => brand = b),
        onMode: (m) => setState(() => mode = m),
        onTab: (t) => setState(() => tab = t),
      ),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({
    super.key,
    required this.brand,
    required this.mode,
    required this.tab,
    required this.onBrand,
    required this.onMode,
    required this.onTab,
  });

  final Brand brand;
  final Mode mode;
  final int tab;
  final ValueChanged<Brand> onBrand;
  final ValueChanged<Mode> onMode;
  final ValueChanged<int> onTab;

  static const items = [
    UiNavItem(
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      label: 'Overview',
    ),
    UiNavItem(
      icon: Icons.widgets_outlined,
      activeIcon: Icons.widgets_rounded,
      label: 'Components',
    ),
    UiNavItem(
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers_rounded,
      label: 'Overlays',
    ),
    UiNavItem(
      icon: Icons.palette_outlined,
      activeIcon: Icons.palette_rounded,
      label: 'Theme',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OverviewPage(),
      const ComponentsPage(),
      const OverlaysPage(),
      ThemePage(brand: brand, mode: mode, onBrand: onBrand, onMode: onMode),
    ];
    return Scaffold(
      body: UiShell(
        items: items,
        selectedIndex: tab,
        onSelected: onTab,
        action: UiNavAction(
          icon: Icons.add_rounded,
          label: 'New appointment',
          onPressed: () => showUiToast(
            context,
            'Appointment created',
            subtitle: 'Tomorrow at 09:30 with Dr. Ruiz',
            actionLabel: 'Undo',
          ),
          onLongPress: () => showUiSheet<void>(
            context: context,
            builder: (_) => const QuickCreateSheet(),
          ),
        ),
        railLeading: const _Logo(),
        body: UiScreenSwitcher(screenKey: tab, index: tab, child: pages[tab]),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ui.colors.accent, ui.colors.accentAlt],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.local_hospital_rounded, color: ui.colors.background),
    );
  }
}
