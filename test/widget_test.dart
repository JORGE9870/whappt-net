import 'package:flutter_test/flutter_test.dart';
import 'package:whappsat/main.dart';

void main() {
  testWidgets('WhatsApp Clone smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WhatsAppClone());

    // Verify that the title is present.
    expect(find.text('Ingresa tu número de teléfono'), findsOneWidget);
  });
}
