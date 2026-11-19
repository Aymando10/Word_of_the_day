import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_of_the_day/app_controller.dart';
import 'package:word_of_the_day/main.dart';
import 'package:word_of_the_day/services/storage.dart';

import 'app_controller_test.dart' show FakeNotifications, FakeWidgetSync;

void main() {
  testWidgets('shows today\'s word and navigates between tabs', (tester) async {
    final controller = AppController(
      store: InMemoryStore(),
      widgetSync: FakeWidgetSync(),
      notifications: FakeNotifications(),
      clock: () => DateTime(2026, 11, 19, 8),
    );

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
    await tester.scrollUntilVisible(
      find.text('Niche'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Niche'), findsOneWidget);
  });
}
