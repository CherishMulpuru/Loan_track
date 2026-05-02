// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loantrack_mobile/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders email and password fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    expect(find.text('LoanTrack'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('LoginScreen shows loading indicator on submit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

    await tester.enterText(find.byType(TextField).first, 'test@test.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Loading state should be triggered (CircularProgressIndicator)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
