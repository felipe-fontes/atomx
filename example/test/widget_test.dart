import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atomx/atomx.dart';

import '../lib/main.dart';

void main() {
  group('Counter App Widget Tests', () {
    testWidgets('Initial state shows zero and ready to start',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial state
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Ready to start'), findsOneWidget);
      expect(find.text('You have pushed the button this many times:'),
          findsOneWidget);
    });

    testWidgets('Increment button increases counter and shows counting state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Initial state verification
      expect(find.text('0'), findsOneWidget);

      // Tap increment button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify counter increased and state changed
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Counting...'), findsOneWidget);
    });

    testWidgets('Pause button changes state', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Tap increment first to enable pause
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Tap pause button
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Verify state changed to paused
      expect(find.text('Paused'), findsOneWidget);
      
      // Verify increment button is disabled in paused state
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      
      // Counter should still show 1 as increment is disabled
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Reset button returns to initial state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Increment a few times
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('2'), findsOneWidget);

      // Tap reset button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Verify return to initial state
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Ready to start'), findsOneWidget);
    });
  });
} 