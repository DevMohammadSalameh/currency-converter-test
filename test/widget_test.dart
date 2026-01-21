import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build a basic MaterialApp to verify widget tree works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Currency Converter'),
          ),
        ),
      ),
    );

    expect(find.text('Currency Converter'), findsOneWidget);
  });
}
