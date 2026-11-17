import 'package:flutter_test/flutter_test.dart';

import 'package:binasbas_navigation_app/main.dart';

void main() {
  testWidgets('App starts with LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
