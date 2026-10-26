import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_theme/flutter_ui_theme.dart';

import 'helpers.dart';

Widget _opener(Future<void> Function(BuildContext) open) => Builder(
  builder: (context) =>
      TextButton(onPressed: () => open(context), child: const Text('open')),
);

void main() {
  group('showUiSheet', () {
    testWidgets('opens as a bottom sheet on narrow windows and closes', (
      tester,
    ) async {
      await pumpUi(
        tester,
        _opener(
          (c) => showUiSheet<void>(
            context: c,
            builder: (_) => const SizedBox(
              height: 200,
              child: Center(child: Text('sheet')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(uiGlassOpenCount.value, 1);

      Navigator.of(tester.element(find.text('sheet'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsNothing);
      expect(uiGlassOpenCount.value, 0);
      expect(uiGlassShownCount.value, 0);
    });

    testWidgets('opens as a centered panel on wide windows', (tester) async {
      await pumpUi(
        tester,
        _opener(
          (c) => showUiSheet<void>(
            context: c,
            builder: (_) => const SizedBox(
              height: 200,
              child: Center(child: Text('panel')),
            ),
          ),
        ),
        size: const Size(1400, 900),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('panel'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      final panel = tester.getRect(
        find
            .ancestor(of: find.text('panel'), matching: find.byType(Material))
            .first,
      );
      expect(panel.width, lessThanOrEqualTo(520));
      expect(panel.center.dx, closeTo(700, 1));
    });

    testWidgets('adaptive: false keeps the bottom sheet on wide windows', (
      tester,
    ) async {
      await pumpUi(
        tester,
        _opener(
          (c) => showUiSheet<void>(
            context: c,
            adaptive: false,
            builder: (_) => const SizedBox(height: 120, child: Text('sheet')),
          ),
        ),
        size: const Size(1400, 900),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('can be dismissed by tapping the barrier', (tester) async {
      await pumpUi(
        tester,
        _opener(
          (c) => showUiSheet<void>(
            context: c,
            builder: (_) => const SizedBox(height: 100, child: Text('sheet')),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(find.text('sheet'), findsNothing);
    });
  });

  group('showUiConfirm', () {
    Future<bool?> run(
      WidgetTester tester,
      String tap, {
      bool danger = false,
    }) async {
      bool? result;
      await pumpUi(
        tester,
        _opener((c) async {
          result = await showUiConfirm(
            c,
            title: 'Delete record?',
            body: 'This cannot be undone.',
            confirmLabel: 'Delete',
            danger: danger,
          );
        }),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete record?'), findsOneWidget);
      await tester.tap(find.text(tap));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('confirm resolves true', (tester) async {
      expect(await run(tester, 'Delete', danger: true), isTrue);
    });

    testWidgets('cancel resolves false', (tester) async {
      expect(await run(tester, 'Cancel'), isFalse);
    });
  });

  group('showUiToast', () {
    testWidgets('appears then dismisses itself', (tester) async {
      Future<void>? done;
      await pumpUi(
        tester,
        _opener((c) async {
          done = showUiToast(
            c,
            'Appointment saved',
            subtitle: 'Tomorrow 09:30',
            actionLabel: 'Undo',
          );
        }),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Appointment saved'), findsOneWidget);
      expect(find.text('Tomorrow 09:30'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Appointment saved'), findsNothing);
      await expectLater(done, completes);
    });

    testWidgets('a new toast replaces the current one', (tester) async {
      await pumpUi(
        tester,
        Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => showUiToast(context, 'first'),
                child: const Text('one'),
              ),
              TextButton(
                onPressed: () => showUiToast(context, 'second'),
                child: const Text('two'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('one'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('two'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping runs onTap and dismisses', (tester) async {
      var taps = 0;
      await pumpUi(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showUiToast(
              context,
              'Tap me',
              onTap: () => taps++,
              position: UiToastPosition.bottom,
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(find.text('Tap me'), findsNothing);
    });
  });

  testWidgets(
    'UiEdgeBlur renders without a shader (test environment fallback)',
    (tester) async {
      await pumpUi(
        tester,
        const SizedBox(
          height: 300,
          width: 300,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: Colors.red)),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: UiEdgeBlur(height: 80),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: UiEdgeBlur(height: 80, top: false),
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
