import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'helpers.dart';

void main() {
  group('UiPrimaryButton', () {
    testWidgets('calls onPressed', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        UiPrimaryButton(label: 'Save', onPressed: () => taps++),
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('does nothing when disabled', (tester) async {
      await pumpUi(
        tester,
        const UiPrimaryButton(label: 'Save', onPressed: null),
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading shows a spinner and blocks taps', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        UiPrimaryButton(label: 'Save', loading: true, onPressed: () => taps++),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('activates from the keyboard', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        UiPrimaryButton(label: 'Save', onPressed: () => taps++),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('shrinks while pressed and recovers', (tester) async {
      await pumpUi(tester, UiPrimaryButton(label: 'Save', onPressed: () {}));
      final scale = find.descendant(
        of: find.byType(UiPressable),
        matching: find.byType(AnimatedScale),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Save')),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.widget<AnimatedScale>(scale).scale, lessThan(1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedScale>(scale).scale, 1);
    });

    testWidgets('does not shrink when animations are disabled', (tester) async {
      await pumpUi(
        tester,
        UiPrimaryButton(label: 'Save', onPressed: () {}),
        disableAnimations: true,
      );
      final scale = find.descendant(
        of: find.byType(UiPressable),
        matching: find.byType(AnimatedScale),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Save')),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.widget<AnimatedScale>(scale).scale, 1);
      await gesture.up();
    });
  });

  testWidgets('UiSecondaryButton, UiPill and UiRoundButton are tappable', (
    tester,
  ) async {
    var taps = <String>[];
    await pumpUi(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiSecondaryButton(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: () => taps.add('secondary'),
          ),
          UiPill(label: 'Today', onPressed: () => taps.add('pill')),
          UiRoundButton(
            icon: Icons.add,
            semanticLabel: 'Add',
            onPressed: () => taps.add('round'),
          ),
        ],
      ),
    );
    await tester.tap(find.text('Cancel'));
    await tester.tap(find.text('Today'));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(taps, ['secondary', 'pill', 'round']);
  });

  testWidgets('UiSwitch reports the toggled value', (tester) async {
    bool? seen;
    await pumpUi(tester, UiSwitch(value: false, onChanged: (v) => seen = v));
    await tester.tap(find.byType(UiSwitch));
    await tester.pumpAndSettle();
    expect(seen, isTrue);
  });

  testWidgets('UiSegmentedToggle reports the tapped segment', (tester) async {
    String? seen;
    await pumpUi(
      tester,
      UiSegmentedToggle<String>(
        segments: const [
          UiSegment(value: 'd', label: 'Day'),
          UiSegment(value: 'w', label: 'Week'),
        ],
        value: 'd',
        onChanged: (v) => seen = v,
      ),
    );
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(seen, 'w');
  });

  testWidgets('UiCard with onTap behaves like a button', (tester) async {
    var taps = 0;
    await pumpUi(
      tester,
      UiCard(onTap: () => taps++, child: const Text('Patient')),
    );
    await tester.tap(find.text('Patient'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('UiOptionGroup selects rows and shows the check mark', (
    tester,
  ) async {
    var picked = '';
    await pumpUi(
      tester,
      UiOptionGroup([
        UiOption(
          'Dr. Ruiz',
          onTap: () => picked = 'ruiz',
          selected: true,
          detail: 'Cardiology',
        ),
        UiOption('Dr. Lee', onTap: () => picked = 'lee', icon: Icons.person),
        UiOption('Delete', onTap: () => picked = 'del', danger: true),
      ]),
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.tap(find.text('Dr. Lee'));
    await tester.pumpAndSettle();
    expect(picked, 'lee');
  });

  testWidgets('UiListGroup lays out rows with controls', (tester) async {
    var on = false;
    await pumpUi(
      tester,
      StatefulBuilder(
        builder: (context, set) => UiListGroup([
          UiListRow(
            label: 'Reminders',
            control: UiSwitch(value: on, onChanged: (v) => set(() => on = v)),
          ),
          const UiListRow(label: 'Language', control: Text('English')),
        ]),
      ),
    );
    await tester.tap(find.byType(UiSwitch));
    await tester.pumpAndSettle();
    expect(on, isTrue);
  });

  testWidgets('UiStepper increments, decrements and rolls the value', (
    tester,
  ) async {
    var v = 5;
    await pumpUi(
      tester,
      StatefulBuilder(
        builder: (context, set) => UiStepper(
          value: '$v',
          onDecrement: () => set(() => v--),
          onIncrement: () => set(() => v++),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(v, 6);
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(v, 4);
    expect(find.bySemanticsLabel('4'), findsOneWidget);
  });

  testWidgets('UiSearchField shows a clear button once there is text', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var last = 'x';
    await pumpUi(
      tester,
      UiSearchField(
        controller: controller,
        hint: 'Search patients',
        onChanged: (v) => last = v,
      ),
    );
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    await tester.enterText(find.byType(TextField), 'ana');
    await tester.pump();
    expect(last, 'ana');
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(last, '');
  });

  testWidgets('UiScreenHeader shows title, subtitle, badge and back', (
    tester,
  ) async {
    var back = 0;
    await pumpUi(
      tester,
      SizedBox(
        width: 360,
        child: UiScreenHeader(
          title: 'Visits',
          subtitle: '12 today',
          badge: const UiBadge('Beta'),
          onBack: () => back++,
          actions: const [Icon(Icons.more_horiz)],
        ),
      ),
    );
    expect(find.text('Visits'), findsOneWidget);
    expect(find.text('12 today'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    expect(back, 1);
  });

  testWidgets('UiMarqueeText scrolls only when the text overflows', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const SizedBox(
        width: 120,
        child: UiMarqueeText('A very long clinic department name'),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(
      find.bySemanticsLabel('A very long clinic department name'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'UiRollingText exposes the value to screen readers and animates changes',
    (tester) async {
      var n = 41;
      late StateSetter set;
      await pumpUi(
        tester,
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return UiRollingText('$n', style: const TextStyle(fontSize: 30));
          },
        ),
      );
      expect(find.bySemanticsLabel('41'), findsOneWidget);
      set(() => n = 42);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('42'), findsOneWidget);
    },
  );

  testWidgets('UiShimmer and UiPatternBackground render', (tester) async {
    await pumpUi(
      tester,
      const SizedBox(
        width: 200,
        height: 120,
        child: Stack(
          children: [
            Positioned.fill(
              child: UiPatternBackground(pattern: UiPattern.grid),
            ),
            Positioned.fill(child: UiShimmer(radius: 12)),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('UiGlassSurface renders its child', (tester) async {
    await pumpUi(
      tester,
      const UiGlassSurface(padding: EdgeInsets.all(16), child: Text('glass')),
    );
    expect(find.text('glass'), findsOneWidget);
  });
}
