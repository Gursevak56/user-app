import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery/main.dart';
import 'package:food_delivery/view/home/home_view.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app with a real home page and trigger a frame.
    await tester.pumpWidget(
      const MyApp(
        defaultHome: HomeView(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
