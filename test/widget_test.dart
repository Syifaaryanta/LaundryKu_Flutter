// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:laundry_ku/main.dart';

void main() {
  testWidgets('LaundryKu app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LaundryKuApp());

    // Verify that LaundryKu title is displayed
    expect(find.text('LaundryKu'), findsWidgets);
    
    // Verify that the subtitle is displayed
    expect(find.text('Laundry Service Manager'), findsOneWidget);
    
    // Verify that stat cards are displayed
    expect(find.text('Total Customers'), findsOneWidget);
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('Total Payments'), findsOneWidget);
  });
}
