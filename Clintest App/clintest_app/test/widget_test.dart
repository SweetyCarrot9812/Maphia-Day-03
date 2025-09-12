// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:clintest_real_v1/main.dart';

void main() {
  testWidgets('Clintest app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClintestApp());

    // Verify that our app starts with splash screen
    expect(find.text('Clintest'), findsOneWidget);
    expect(find.text('AI 의료 학습 플랫폼'), findsOneWidget);
  });
}
