# AGENTS.md: adopting `flutter_ui_theme` in an existing Flutter app

Audience: an engineer or coding agent migrating an app (the clinic app, targeting
**Android, macOS and Windows**) from stock Material widgets to this design
system. Read this file top to bottom once, then use the sections as a checklist.

The package is **tokens first**: one `UiTheme` object holds colors, shapes, motion,
typography and effects. Every widget reads it through `context.ui`. You restyle
the app by changing tokens, not widgets.

## 0. Ground rules

1. **Never hardcode** colors, radii, font names, durations or shadows in app code.
   Read them from `context.ui` (`ui.colors`, `ui.shape`, `ui.motion`,
   `ui.typography`, `ui.effects`). If a value is missing, add a token here.
2. **Do not copy widget source into the app.** Depend on the package; fix or extend
   it in this repository.
3. Any custom tappable must use `UiPressable` (springy press, mouse cursor,
   keyboard activation, focus ring, semantics).
4. Every icon-only button needs a `semanticLabel` / `label`.
5. Respect "reduce motion". Widgets here do it automatically; do not bypass it.
6. Keep this package free of app logic and of state-management dependencies. It
   depends on `flutter` only.

## 1. Install

```yaml
# pubspec.yaml of the clinic app
dependencies:
  flutter_ui_theme:
    git:
      url: https://github.com/carlosupreme/flutter-ui-theme
      ref: main   # pin a tag or commit for releases
```

Requires Flutter >= 3.35 (developed and tested on 3.41.9, Dart 3.11).
The Nunito font and the edge-blur shader ship inside the package; the app does not
declare them.

## 2. Migration playbook (do these in order, commit after each)

### Step 1: define the brand once

Create `lib/ui/clinic_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

const clinicColorsLight = UiColors(/* all 23 fields; see example/lib/palettes.dart */);
const clinicColorsDark  = UiColors(/* ... */);

final clinicLight = UiTheme.light.copyWith(colors: clinicColorsLight);
final clinicDark  = UiTheme.dark.copyWith(colors: clinicColorsDark);
```

`example/lib/palettes.dart` contains a complete, AA-checked teal clinic palette in
light, dark and AMOLED. Start from it and change the brand colors. Shape, motion,
blur and typography can stay as they are.

### Step 2: swap the app theme (largest visible win, smallest diff)

```dart
MaterialApp(
  theme: buildUiTheme(clinicLight),
  darkTheme: buildUiTheme(clinicDark),
  themeMode: ThemeMode.system,
  // ...
)
```

`buildUiTheme` restyles the **stock** widgets too: `FilledButton`,
`ElevatedButton`, `OutlinedButton`, `TextButton`, `TextField`, `Switch`,
`Checkbox`, `Chip`, `Card`, `Dialog`, bottom sheets, date and time pickers,
menus, tooltips, `SnackBar`, scrollbars, list tiles and tab bars. It also installs
`UiPageTransitionsBuilder` on every platform, so `Navigator.push`,
`MaterialPageRoute` and go_router pages get the new transition automatically.

Run the app and screenshot every screen before touching any widget. Fix layout
fallout (the pill-shaped buttons are 52px tall, inputs are rounder) before moving on.

### Step 3: replace components

Replace as you touch each screen. Do not do a big bang.

| Stock Flutter | Use instead | Notes |
|---|---|---|
| `ElevatedButton` / `FilledButton` (primary CTA) | `UiPrimaryButton` | `loading`, `icon`, `expand: false` |
| secondary / tonal button | `UiSecondaryButton` | |
| `IconButton` in a circle | `UiRoundButton(semanticLabel: ...)` | `filled: true` for emphasis |
| `ChoiceChip` / `FilterChip` | `UiPill(selected: ...)` | |
| `SegmentedButton` / small tab switch | `UiSegmentedToggle<T>` | |
| `Switch` in a settings row | `UiSwitch` inside `UiListRow` / `UiListGroup` | |
| number stepper | `UiStepper` | digits roll |
| `Card` / `Container` with border | `UiCard` (`onTap` makes it a button) | |
| `ListTile` groups, action lists | `UiOptionGroup` + `UiOption` | `danger`, `selected`, `leading`, `trailing` |
| settings rows with a control | `UiListGroup` + `UiListRow` | |
| search `TextField` | `UiSearchField` | |
| `AppBar` title row inside a body | `UiScreenHeader` | back button, badge, actions |
| status `Chip` / label | `UiBadge` | |
| animated counters | `UiRollingText` | |
| `CircularProgress` placeholders | `UiShimmer` skeletons | |
| `BottomNavigationBar` / `NavigationBar` / `NavigationRail` / `Drawer` | `UiShell` (see Step 4) | |
| `showModalBottomSheet` | `showUiSheet` | becomes a centered panel on wide windows |
| `showDialog` + `AlertDialog` | `showUiDialog` + `uiAlertDialog`, or `showUiConfirm` | |
| `ScaffoldMessenger...showSnackBar` | `showUiToast` | top or bottom, auto-dismiss |
| `AnimatedSwitcher` between tab bodies | `UiScreenSwitcher` | direction is automatic |
| staggered list entrances | `riseAll([...])`, `Rise(index:)` | wrap a screen in `UiRiseScope(enabled: ...)` to play once |

### Step 4: the app shell (mobile and desktop from one widget)

```dart
UiShell(
  items: const [
    UiNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Today'),
    UiNavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Patients'),
    UiNavItem(icon: Icons.event_outlined, activeIcon: Icons.event_rounded, label: 'Agenda', badge: 3),
    UiNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ],
  selectedIndex: tab,
  onSelected: (i) => setState(() => tab = i),   // or go_router: context.go(paths[i])
  action: UiNavAction(icon: Icons.add_rounded, label: 'New appointment', onPressed: ...),
  railLeading: const ClinicLogo(),
  body: UiScreenSwitcher(screenKey: tab, index: tab, child: pages[tab]),
)
```

* Below 840 px wide it is a floating glass `UiNavBar` over the content, with the
  progressive blur. At or above 840 px it is a `UiNavRail` (labels shown from
  1280 px). Override with `railBreakpoint` / `extendedBreakpoint`.
* `body` gets `MediaQuery.padding.bottom` reserved for the floating bar. Use
  `ListView` / `SingleChildScrollView` with their default padding, or add
  `MediaQuery.paddingOf(context).bottom` yourself. Do not add a second bottom bar.
* With go_router, use `StatefulShellRoute` and pass `navigationShell.currentIndex`
  / `goBranch` into `selectedIndex` / `onSelected`; keep `UiScreenSwitcher` around
  the shell's child.
* `UiNavBar` always lays out left-to-right. For RTL locales, reverse `items`.
* Max 6 items (the bar asserts). Move the rest into a "More" sheet.

### Step 5: overlays

* `showUiSheet(context: ..., builder: ...)`: pad content with `uiSheetPadding(context)`,
  start with `UiSheetHandle()` (it hides itself on desktop panels), then
  `UiSheetTitle`, `UiOptionGroup`, buttons.
* `showUiConfirm(context, title:, body:, confirmLabel:, danger: true)` returns a
  `bool`; use `danger` for deletions and cancellations.
* `showUiToast(context, 'Saved', subtitle: ..., actionLabel: 'Undo', onTap: ...)`.
  One toast at a time; a new one replaces the current one.
* `uiGlassOpenCount` is a `ValueListenable<int>` of open sheets/dialogs, if you
  need to react (for example, pause a video).

### Step 6: desktop (macOS and Windows)

Already handled: mouse cursor and keyboard activation on every `UiPressable`
(Enter and Space), focus ring, side rail, centered sheet panels, themed scrollbars,
hover/focus colors, `Tooltip` on the collapsed rail.

Still on you in the app:

* **Constrain content width.** Phone-shaped screens stretched over 1920 px look
  broken. Wrap page bodies in `Center` + `ConstrainedBox(maxWidth: 760..1100)` (see
  `_Page` in `example/lib/pages.dart`) or use a master-detail split above ~1100 px.
* Add keyboard shortcuts for frequent actions with `Shortcuts` / `CallbackShortcuts`.
* Hover affordances for dense tables or lists (the package only does it for
  buttons, nav items and cards).
* Windows and macOS window sizing and minimum size (use `window_manager` or the
  platform runner); Android back handling is the app's job.
* Haptics (`HapticFeedback`) are phone-only and silently do nothing on desktop.
* Heavy `BackdropFilter` blur can be slow on low-end Windows PCs. If a clinic
  front-desk machine stutters, lower `UiEffects.navBlur` / `sheetBlur` / `glassBlur`
  via `UiTheme.copyWith(effects: ...)` or pass `blurEdges: false` to `UiShell`.

### Step 7: notifications

This package only does **in-app** feedback (`showUiToast`). OS notifications are
the app's job and independent of the UI:

* Local reminders: `flutter_local_notifications` (Android, macOS, Windows, Linux,
  iOS). No push provider needed for appointment reminders scheduled on the device.
  Windows needs an app identity (MSIX packaging) for toast notifications; macOS
  needs notification entitlements; Android 12+ exact alarms need
  `SCHEDULE_EXACT_ALARM` or inexact fallback.
* Server push (cancellations, messages) needs FCM / APNs / WNS. Decide this with
  the product owner before building.
* Keep a thin `NotificationService` interface in the app so UI code only calls
  `notifier.show(...)`.

## 3. Accessibility checklist (this is a medical product)

Measured contrast (WCAG 2.x; body text needs 4.5:1, large text and UI parts 3:1):

| Pair | Ratio |
|---|---|
| built-in dark: `textTertiary` on `background` | **3.45** (fails for small text) |
| built-in light: `textTertiary` on `background` | **3.48** (fails for small text) |
| built-in light: `accent` on `surface` | 5.88 |
| example clinic light: `textTertiary` on `background` | 5.08 |
| example clinic light: `accent` on `surface` | 5.43 |
| example clinic light: `onPrimary` on `primary` | 6.16 |
| example clinic dark: `textTertiary` on `background` | 6.11 |

Rules:

* The nav bar uses `textTertiary` for unselected labels. Keep it at least 4.5:1 in
  your palette, or pass `UiNavBar(unselectedColor: colors.textSecondary)`.
* `accent` is used as **text** (dialog actions, links, badges). It must reach 4.5:1
  on `surface` and `surfaceAlt`.
* Verify any new palette with a script before shipping; do not eyeball it.
* Test with 200% text scale and with OS "reduce motion".
* Screen readers: all package widgets expose semantics; icon-only buttons need your
  `semanticLabel`.
* Do not convey status by color alone (`UiBadge` carries a text label).

## 4. Testing in the app

```dart
await tester.pumpWidget(MaterialApp(theme: buildUiTheme(clinicLight), home: ...));
```

* Always build the test app with `buildUiTheme`, not `ThemeData()`.
* In widget tests the bundled font is not loaded, so text renders in the wide
  "Ahem" test font. Do not assert on text overflow with it, and keep fixed-width
  test containers generous.
* After `Navigator.push`, call `pump()` once, then `pump(duration)`; the first frame
  of a route is offstage.
* Use `MediaQuery(data: ..., disableAnimations: true)` to skip animations.

## 5. Extending the package

* One concern per file under `lib/src/{tokens,transitions,widgets,navigation,overlays}`.
* New widget: read everything from `context.ui`, wrap taps in `UiPressable`, add a
  test in `test/`, add a section in `example/lib/pages.dart`, export it from
  `lib/flutter_ui_theme.dart`, and add a row to the mapping table above.
* Do **not** use `late final x = widget.something;` field initializers in `State`
  classes. They run lazily, after the widget may already have changed. Initialize in
  `initState` (this caused a real bug in `UiScreenSwitcher`, now covered by a test).
* Run before committing:

```bash
flutter analyze
flutter test
cd example && flutter analyze
```

* Visual check: `cd example && flutter create --platforms=macos,windows,android,web .`
  (generated folders are git-ignored), then `flutter run -d macos` or
  `flutter run -d chrome`. URL parameters on web select the theme:
  `?mode=light&brand=clinic&tab=2`.

## 6. API cheat sheet

```text
Theme      UiTheme{colors,shape,motion,typography,effects}  buildUiTheme(ui)  context.ui
Colors     UiColors.light / .dark / .amoled (+ copyWith)
Text       ui.typography.strong(size) / .body(size) / .display(size)
Buttons    UiPrimaryButton UiSecondaryButton UiPill UiRoundButton UiSegmentedToggle<T>
           UiSwitch UiStepper UiPressable
Surfaces   UiCard UiGlassSurface UiBadge UiShimmer UiPatternBackground
           UiSheetHandle UiSheetTitle uiSheetPadding()
Lists      UiOptionGroup/UiOption UiListGroup/UiListRow
Inputs     UiSearchField UiScreenHeader UiMarqueeText UiRollingText
Nav        UiShell UiNavBar UiNavRail UiNavItem UiNavAction
Motion     UiScreenSwitcher UiPageTransitionsBuilder Rise riseAll UiRiseScope
Overlays   showUiSheet showUiDialog showUiConfirm uiAlertDialog uiDialogAction
           showUiToast UiEdgeBlur uiGlassOpenCount
```

## 7. Known limitations

* The original app's "liquid notch" toast (an animation that grows out of the
  phone's camera cutout) is intentionally not included; `showUiToast` is the
  desktop-safe equivalent. Say so if you want the notch version ported for phones.
* `UiNavBar` is capped at 6 items and always left-to-right.
* Switching between light and dark animates: `MaterialApp` interpolates `ThemeData`, and `UiTheme.lerp` interpolates the colors and radii (motion, typography and effects switch at the midpoint).
* The fragment-shader edge blur needs Impeller or Skia with shader filter support;
  otherwise it falls back to stacked blur strips automatically.
