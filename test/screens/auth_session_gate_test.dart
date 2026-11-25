import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/screens/auth_session_gate.dart';

void main() {
  testWidgets(
    'restored session opens the app and lost session returns to auth',
    (WidgetTester tester) async {
      final sessionChanges = StreamController<bool>.broadcast();
      await tester.pumpWidget(
        MaterialApp(
          home: AuthSessionGate(
            initiallyAuthenticated: true,
            sessionChanges: sessionChanges.stream,
            authenticatedBuilder: (_) =>
                const Scaffold(body: Text('Daftar Kos')),
            unauthenticatedBuilder: (_, _) =>
                const Scaffold(body: Text('Masuk')),
          ),
        ),
      );

      expect(find.text('Daftar Kos'), findsOneWidget);

      sessionChanges.add(false);
      await tester.pumpAndSettle();
      expect(find.text('Masuk'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await sessionChanges.close();
    },
  );

  testWidgets('authentication callback opens the app before stream update', (
    WidgetTester tester,
  ) async {
    final sessionChanges = StreamController<bool>.broadcast();
    await tester.pumpWidget(
      MaterialApp(
        home: AuthSessionGate(
          initiallyAuthenticated: false,
          sessionChanges: sessionChanges.stream,
          authenticatedBuilder: (_) => const Scaffold(body: Text('Daftar Kos')),
          unauthenticatedBuilder: (_, onAuthenticated) => Scaffold(
            body: TextButton(
              onPressed: onAuthenticated,
              child: const Text('Masuk'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Daftar Kos'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await sessionChanges.close();
  });
}
