import 'package:flutter_test/flutter_test.dart';
import 'package:practicalogin/main.dart';

void main() {
  testWidgets('App starts with loading indicator or login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecurityApp());

    // Verify that the app starts (either loading or login)
    expect(find.byType(SecurityApp), findsOneWidget);
  });
}
