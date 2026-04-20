import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Core App test', (WidgetTester tester) async {
    // Just verifying the basic material app scaffold works
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Test Environment')),
        ),
      ),
    );
    expect(find.text('Test Environment'), findsOneWidget);
  });
}
