import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hms_mobile/main.dart';
import 'package:hms_mobile/core/auth/auth_state.dart';

void main() {
  testWidgets('Ceylon Heritage HMS App boots into Login Screen, unlocks via PIN, and logs out', (WidgetTester tester) async {
    // Set viewport size for mobile testing
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Ensure initial unauthenticated state
    final auth = AuthState();
    auth.logout();

    // 2. Build the Ceylon HMS application
    await tester.pumpWidget(const CeylonHmsApp());
    await tester.pumpAndSettle();

    // 3. Verify Login Screen is displayed
    expect(find.text('Ceylon Heritage HMS'), findsOneWidget);
    expect(find.text('Quick PIN Shift'), findsOneWidget);
    expect(find.text('Staff Sign In'), findsOneWidget);
    expect(find.textContaining('GM / Admin (1234)'), findsOneWidget);

    // 4. Tap the GM / Admin demo quick preset chip
    final chipFinder = find.textContaining('GM / Admin (1234)');
    await tester.ensureVisible(chipFinder);
    await tester.tap(chipFinder);
    await tester.pumpAndSettle();

    // 5. Verify transition to AppShell (authenticated)
    expect(auth.isAuthenticated, isTrue);
    expect(find.textContaining('CBSL 1:LKR'), findsOneWidget);
    expect(find.text('Cloud'), findsOneWidget);

    // 6. Test logging out returns to Login Screen
    auth.logout();
    await tester.pumpAndSettle();

    expect(auth.isAuthenticated, isFalse);
    expect(find.text('Quick PIN Shift'), findsOneWidget);
  });
}
