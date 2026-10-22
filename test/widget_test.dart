import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/main.dart';
import 'package:hms_mobile/core/auth/auth_state.dart';

void main() {
  testWidgets('Ceylon Heritage HMS App boots up and displays initial UI', (WidgetTester tester) async {
    // Ensure initial authenticated demo state
    AuthState().switchRole(UserRole.hotelAdmin);

    // Build the Ceylon HMS application
    await tester.pumpWidget(const CeylonHmsApp());
    await tester.pumpAndSettle();

    // Verify presence of Top Status Bar elements
    expect(find.textContaining('CBSL 1:LKR'), findsOneWidget);
    expect(find.text('Cloud'), findsOneWidget);

    // Verify Executive Command / Touchpoints Hub title
    expect(find.text('Ceylon Heritage HMS'), findsOneWidget);
  });
}
