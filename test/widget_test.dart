import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/app.dart';

void main() {
  testWidgets('Lumo displays splash screen and navigates to home', (
    WidgetTester tester,
  ) async {
    // Launch the real Lumo application.
    await tester.pumpWidget(const LumoApp());

    // Confirm that the splash screen appears first.
    expect(find.text('lumo'), findsOneWidget);

    // Advance past the splash screen's two-second delay.
    // Avoid pumpAndSettle because the splash animation repeats.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    // Verify the physical-shop discovery journey on the home screen.
    expect(find.text('Products at local shops'), findsOneWidget);
    expect(find.text('Find a shop. Then plan your visit.'), findsOneWidget);
    expect(find.text('Explore nearby'), findsOneWidget);
  });
}
