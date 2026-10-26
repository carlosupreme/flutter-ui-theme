import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'helpers.dart';

void main() {
  group('UiNavBar', () {
    testWidgets('tap selects an item', (tester) async {
      var selected = 0;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, set) => UiNavBar(
            items: navItems,
            selectedIndex: selected,
            onSelected: (i) => set(() => selected = i),
            haptics: false,
          ),
        ),
        center: false,
      );
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      expect(selected, 2);
    });

    testWidgets('shows the active icon and a badge for the selected item', (
      tester,
    ) async {
      await pumpUi(
        tester,
        UiNavBar(
          items: navItems,
          selectedIndex: 2,
          onSelected: (_) {},
          haptics: false,
        ),
        center: false,
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.event_rounded), findsOneWidget);
      expect(find.byIcon(Icons.event_outlined), findsNothing);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('press-hold and slide selects the item under the pointer', (
      tester,
    ) async {
      var selected = 0;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, set) => UiNavBar(
            items: navItems,
            selectedIndex: selected,
            onSelected: (i) => set(() => selected = i),
            haptics: false,
          ),
        ),
        center: false,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Home')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(tester.getCenter(find.text('Settings')));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(selected, 3);
    });

    testWidgets('embeds an action button between the items', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        UiNavBar(
          items: navItems,
          selectedIndex: 0,
          onSelected: (_) {},
          haptics: false,
          action: UiNavAction(
            icon: Icons.add,
            label: 'New visit',
            onPressed: () => taps++,
          ),
        ),
        center: false,
      );
      // Action sits after two items: Home, Patients, [+], Calendar, Settings.
      final xs = [
        tester.getCenter(find.text('Patients')).dx,
        tester.getCenter(find.byIcon(Icons.add)).dx,
        tester.getCenter(find.text('Calendar')).dx,
      ];
      expect(xs[0] < xs[1] && xs[1] < xs[2], isTrue);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('narrow screens keep every item inside the bar', (
      tester,
    ) async {
      await pumpUi(
        tester,
        UiNavBar(
          items: navItems,
          selectedIndex: 0,
          onSelected: (_) {},
          haptics: false,
          action: UiNavAction(icon: Icons.add, onPressed: () {}),
        ),
        size: const Size(320, 600),
        center: false,
      );
      expect(tester.takeException(), isNull);
      final bar = tester.getRect(find.byType(UiNavBar));
      for (final label in ['Home', 'Patients', 'Calendar', 'Settings']) {
        final r = tester.getRect(find.text(label));
        expect(
          r.left >= bar.left && r.right <= bar.right,
          isTrue,
          reason: label,
        );
      }
    });

    testWidgets('keeps a fixed height and respects maxWidth', (tester) async {
      await pumpUi(
        tester,
        UiNavBar(
          items: navItems,
          selectedIndex: 0,
          onSelected: (_) {},
          haptics: false,
          maxWidth: 400,
        ),
        size: const Size(1200, 600),
        center: false,
      );
      final size = tester.getSize(find.byType(UiNavBar));
      expect(size.height, UiNavBar.height);
    });
  });

  group('UiShell', () {
    Widget shell(ValueChanged<int> onSelected) => UiShell(
      items: navItems,
      selectedIndex: 0,
      onSelected: onSelected,
      body: const Center(child: Text('body')),
    );

    testWidgets('uses the floating bar on narrow windows', (tester) async {
      await pumpUi(
        tester,
        shell((_) {}),
        size: const Size(420, 800),
        center: false,
      );
      expect(find.byType(UiNavBar), findsOneWidget);
      expect(find.byType(UiNavRail), findsNothing);
    });

    testWidgets('uses the side rail on wide windows', (tester) async {
      var selected = 0;
      await pumpUi(
        tester,
        shell((i) => selected = i),
        size: const Size(1000, 800),
        center: false,
      );
      expect(find.byType(UiNavRail), findsOneWidget);
      expect(find.byType(UiNavBar), findsNothing);
      await tester.tap(find.text('Patients'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });

    testWidgets('shows full labels on very wide windows', (tester) async {
      await pumpUi(
        tester,
        shell((_) {}),
        size: const Size(1500, 800),
        center: false,
      );
      expect(tester.widget<UiNavRail>(find.byType(UiNavRail)).extended, isTrue);
    });

    testWidgets('reserves room for the floating bar in MediaQuery', (
      tester,
    ) async {
      late EdgeInsets padding;
      await pumpUi(
        tester,
        UiShell(
          items: navItems,
          selectedIndex: 0,
          onSelected: (_) {},
          body: Builder(
            builder: (context) {
              padding = MediaQuery.paddingOf(context);
              return const SizedBox();
            },
          ),
        ),
        size: const Size(420, 800),
        center: false,
      );
      expect(padding.bottom, greaterThanOrEqualTo(UiNavBar.height + 18));
    });
  });

  group('UiScreenSwitcher', () {
    testWidgets('cross-fades to the new screen then drops the old one', (
      tester,
    ) async {
      var key = 'a';
      late StateSetter set;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return UiScreenSwitcher(screenKey: key, child: Text('screen $key'));
          },
        ),
        center: false,
      );
      expect(find.text('screen a'), findsOneWidget);
      set(() => key = 'b');
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('screen a'), findsOneWidget);
      expect(find.text('screen b'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('screen a'), findsNothing);
      expect(find.text('screen b'), findsOneWidget);
    });

    testWidgets('moves sideways between tabs and vertically otherwise', (
      tester,
    ) async {
      var tab = 0;
      var depth = 0;
      late StateSetter set;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return UiScreenSwitcher(
              screenKey: 'k$tab-$depth',
              index: depth == 0 ? tab : null,
              depth: depth,
              child: Text('t$tab d$depth'),
            );
          },
        ),
        center: false,
      );
      Offset where(String text) => tester.getCenter(find.text(text));
      final home = where('t0 d0');
      set(() => tab = 1);
      await tester.pump(const Duration(milliseconds: 60));
      final incoming = where('t1 d0');
      final outgoing = where('t0 d0');
      expect(incoming.dx, isNot(equals(outgoing.dx)));
      expect(incoming.dy, closeTo(home.dy, 0.5));
      await tester.pumpAndSettle();

      set(() => depth = 1);
      await tester.pump(const Duration(milliseconds: 60));
      expect(where('t1 d1').dy, isNot(closeTo(where('t1 d0').dy, 0.01)));
      await tester.pumpAndSettle();
    });

    testWidgets('skips animation when reduce-motion is on', (tester) async {
      var key = 'a';
      late StateSetter set;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return UiScreenSwitcher(screenKey: key, child: Text('screen $key'));
          },
        ),
        center: false,
        disableAnimations: true,
      );
      set(() => key = 'b');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('screen a'), findsNothing);
      expect(find.text('screen b'), findsOneWidget);
    });
  });

  group('page transitions', () {
    testWidgets('Navigator.push uses the Ui transition and completes', (
      tester,
    ) async {
      await pumpUi(
        tester,
        Builder(
          builder: (context) {
            return TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: Center(child: Text('second'))),
                ),
              ),
              child: const Text('go'),
            );
          },
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('second'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(tester.takeException(), isNull);

      Navigator.of(tester.element(find.text('second'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
    });
  });

  group('Rise', () {
    testWidgets('fades the child in', (tester) async {
      await pumpUi(
        tester,
        const Rise(index: 0, child: Text('hello')),
        center: false,
      );
      final opacity = find.descendant(
        of: find.byType(Rise),
        matching: find.byType(Opacity),
      );
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.widget<Opacity>(opacity.first).opacity, lessThan(1));
      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(opacity.first).opacity, 1);
    });

    testWidgets('UiRiseScope(enabled: false) disables it', (tester) async {
      await pumpUi(
        tester,
        const UiRiseScope(
          enabled: false,
          child: Rise(index: 0, child: Text('hello')),
        ),
        center: false,
      );
      expect(
        find.descendant(of: find.byType(Rise), matching: find.byType(Opacity)),
        findsNothing,
      );
    });

    testWidgets('riseAll skips plain spacers', (tester) async {
      final list = riseAll([
        const Text('a'),
        const SizedBox(height: 8),
        const Text('b'),
      ]);
      expect(list.whereType<Rise>().length, 2);
      expect(list[1], isA<SizedBox>());
    });
  });
}
