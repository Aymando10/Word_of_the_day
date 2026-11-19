import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/app_controller.dart';
import 'package:word_of_the_day/main.dart';
import 'package:word_of_the_day/services/storage.dart';

import 'app_controller_test.dart' show FakeNotifications, FakeWidgetSync;

AppController _controller(InMemoryStore store) => AppController(
  store: store,
  widgetSync: FakeWidgetSync(),
  notifications: FakeNotifications(),
  clock: () => DateTime(2026, 11, 19, 8),
);

/// The guide's illustrations animate forever, so step time instead of settling.
Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('first launch walks through the widget guide', (tester) async {
    final store = InMemoryStore();
    final controller = _controller(store);

    await tester.pumpWidget(WordApp(controller: controller));
    await _pumpFrames(tester);

    expect(find.text('A new word, every day'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    for (final title in [
      'Touch and hold',
      'Tap Edit, then Add Widget',
      'Find Word of the Day',
      'Place it and tap Done',
    ]) {
      await tester.tap(find.text('Next'));
      await _pumpFrames(tester);
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(controller.hasSeenOnboarding, isTrue);
    expect(store.values['onboarding_done'], 'true');
    expect(find.text('Word of the Day'), findsOneWidget);
  });

  testWidgets('skipping the guide goes straight to the app', (tester) async {
    final controller = _controller(InMemoryStore());

    await tester.pumpWidget(WordApp(controller: controller));
    await _pumpFrames(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(controller.hasSeenOnboarding, isTrue);
    expect(find.text(controller.today.word), findsWidgets);
  });

  testWidgets('returning users see today\'s word and can reopen the guide', (
    tester,
  ) async {
    final controller = _controller(InMemoryStore({'onboarding_done': 'true'}));

    await tester.pumpWidget(WordApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Word of the Day'), findsOneWidget);
    expect(find.text(controller.today.word), findsWidgets);

    await tester.tap(find.byIcon(Icons.bookmark_border).first);
    await tester.pumpAndSettle();
    expect(controller.isFavorite(controller.today), isTrue);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);

    final settingsList = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      find.text('Niche'),
      200,
      scrollable: settingsList,
    );
    expect(find.text('Niche'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('How to add the widget'),
      200,
      scrollable: settingsList,
    );
    await tester.tap(find.text('How to add the widget'));
    await _pumpFrames(tester);
    expect(find.text('A new word, every day'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('How to add the widget'), findsOneWidget);
  });
}
