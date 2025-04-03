import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galerio_demo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify app title is displayed
    expect(find.text('Galerio Demo'), findsOneWidget);

    // Verify Firebase test text is displayed
    expect(find.text('Firebase Initialization Test'), findsOneWidget);

    // Verify AppBar exists
    expect(find.byType(AppBar), findsOneWidget);
  });
}
