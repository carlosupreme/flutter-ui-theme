import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'helpers.dart';

void main() {
  group('buildUiTheme', () {
    test('registers the UiTheme extension for every preset', () {
      for (final ui in [UiTheme.light, UiTheme.dark, UiTheme.amoled]) {
        final theme = buildUiTheme(ui);
        expect(theme.extension<UiTheme>(), same(ui));
        expect(
          theme.brightness,
          ui.isDark ? Brightness.dark : Brightness.light,
        );
        expect(theme.scaffoldBackgroundColor, ui.colors.background);
      }
    });

    test('uses the bundled font from the package', () {
      final theme = buildUiTheme(UiTheme.light);
      final style = theme.textTheme.bodyMedium!;
      expect(style.fontFamily, 'packages/flutter_ui_theme/Nunito');
    });

    test('a custom font replaces the bundled one', () {
      final ui = UiTheme.light.copyWith(
        typography: const UiTypography(family: 'Inter', package: null),
      );
      expect(buildUiTheme(ui).textTheme.bodyMedium!.fontFamily, 'Inter');
      expect(ui.typography.strong(14).fontFamily, 'Inter');
    });

    test('registers the page transition for every platform', () {
      final builders = buildUiTheme(
        UiTheme.light,
      ).pageTransitionsTheme.builders;
      for (final p in TargetPlatform.values) {
        expect(builders[p], isA<UiPageTransitionsBuilder>());
      }
    });

    test('lerp interpolates colors and snaps motion', () {
      final mid = UiTheme.light.lerp(UiTheme.dark, 0.5);
      expect(
        mid.colors.background,
        Color.lerp(UiColors.light.background, UiColors.dark.background, 0.5),
      );
    });

    test('isDark follows the background', () {
      expect(UiColors.light.isDark, isFalse);
      expect(UiColors.dark.isDark, isTrue);
      expect(UiColors.amoled.isDark, isTrue);
    });
  });

  testWidgets(
    'context.ui falls back when the theme was not built with buildUiTheme',
    (tester) async {
      late UiTheme seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              seen = context.ui;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen.isDark, isTrue);
    },
  );

  testWidgets(
    'every light/dark/amoled theme renders the stock Material widgets',
    (tester) async {
      for (final ui in [UiTheme.light, UiTheme.dark, UiTheme.amoled]) {
        await pumpUi(
          tester,
          SingleChildScrollView(
            child: Column(
              children: [
                FilledButton(onPressed: () {}, child: const Text('Filled')),
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
                const TextField(decoration: InputDecoration(labelText: 'Name')),
                Switch(value: true, onChanged: (_) {}),
                Checkbox(value: true, onChanged: (_) {}),
                const Chip(label: Text('Chip')),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Card'),
                  ),
                ),
                const LinearProgressIndicator(value: .4),
              ],
            ),
          ),
          ui: ui,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Filled'), findsOneWidget);
      }
    },
  );

  testWidgets('stock dialogs and pickers build with the theme', (tester) async {
    await pumpUi(
      tester,
      Builder(
        builder: (context) {
          return Column(
            children: [
              TextButton(
                onPressed: () => showDatePicker(
                  context: context,
                  initialDate: DateTime(2026, 5, 4),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                ),
                child: const Text('date'),
              ),
              TextButton(
                onPressed: () => showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 30),
                ),
                child: const Text('time'),
              ),
            ],
          );
        },
      ),
    );
    await tester.tap(find.text('date'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('time'));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
