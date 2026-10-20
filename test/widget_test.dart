
import 'package:flutter_test/flutter_test.dart';
import 'package:lumo/app.dart';

void main() {
  testWidgets('Lumo displays splash screen and opens home',
          (WidgetTester tester) async {
        // Start the real application.
        await tester.pumpWidget(const LumoApp());

        // The splash screen should appear first.
        expect(find.text('lumo'), findsOneWidget);

        // Allow the splash screen's two-second navigation delay to finish.
        // Do not use pumpAndSettle here because the splash animation repeats.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        // The home screen should now be visible.
        expect(find.text('Products to discover'), findsOneWidget);
        expect(find.text('Local shops to discover'), findsOneWidget);
      });
}
