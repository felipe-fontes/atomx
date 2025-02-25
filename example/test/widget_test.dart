import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';
import '../lib/chat_controller.dart';
import '../lib/contacts_controller.dart';
import '../lib/models.dart';

void main() {
  group('Chat App Widget Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Initial state shows loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Chat Demo'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete (including the 1 second delay)
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Can send a message and see it in the list', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      const testMessage = 'Hello, Bob!';
      
      // Enter and send message
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify message appears
      expect(find.text(testMessage), findsOneWidget);
      
      // TextField should be cleared
      expect(find.widgetWithText(TextField, ''), findsOneWidget);

      // Wait for simulated response (up to 2 seconds delay)
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Simulated response appears after sending message', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      const testMessage = 'Hi there!';
      
      // Send message
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify original message
      expect(find.text(testMessage), findsOneWidget);

      // Wait for simulated response (up to 2 seconds delay)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we have at least 2 ListTiles (original message and response)
      expect(find.byType(ListTile), findsAtLeast(2));

      // Verify one of the possible responses appears
      final hasResponse = tester.any(find.byWidgetPredicate((widget) {
        if (widget is Text) {
          return [
            'Hey! How are you?',
            'That\'s interesting!',
            'Tell me more about it',
            'I see what you mean',
            'Sounds good to me',
          ].contains(widget.data);
        }
        return false;
      }));
      expect(hasResponse, isTrue);
    });

    testWidgets('Empty message cannot be sent', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to send empty message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Verify no ListTiles are shown (no messages)
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Contact names are displayed correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Send a message
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      
      // Wait for message and contact name to appear
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify Alice (sender) name is shown
      expect(find.text('Alice'), findsOneWidget);
    });
  });
} 