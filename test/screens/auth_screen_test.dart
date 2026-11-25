import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/screens/auth_screen.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signInError;
  Object? signUpError;
  Object? googleError;
  int signInCalls = 0;
  int signUpCalls = 0;
  int googleCalls = 0;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    if (signUpError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    googleCalls++;
    if (googleError case final error?) {
      throw error;
    }
  }

  @override
  Future<void> signOut() async {}
}

Future<void> pumpAuthScreen(
  WidgetTester tester,
  AuthProvider provider, {
  required VoidCallback onAuthenticated,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: AuthScreen(provider: provider, onAuthenticated: onAuthenticated),
    ),
  );
}

void main() {
  testWidgets('empty required fields are rejected locally', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository();
    final provider = AuthProvider(repository);
    await pumpAuthScreen(tester, provider, onAuthenticated: () {});

    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
    expect(repository.signInCalls, 0);
    expect(repository.signUpCalls, 0);

    provider.dispose();
  });

  testWidgets('valid registration completes without a verification step', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository();
    final provider = AuthProvider(repository);
    var authenticated = false;
    await pumpAuthScreen(
      tester,
      provider,
      onAuthenticated: () => authenticated = true,
    );

    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'new@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'pass123',
    );
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();

    expect(repository.signUpCalls, 1);
    expect(authenticated, isTrue);

    provider.dispose();
  });

  testWidgets('invalid credentials and connection errors can be retried', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository()
      ..signInError = const AuthFailure.invalidCredentials();
    final provider = AuthProvider(repository);
    var authenticated = false;
    await pumpAuthScreen(
      tester,
      provider,
      onAuthenticated: () => authenticated = true,
    );

    await tester.enterText(
      find.byKey(const ValueKey('auth-email')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('auth-password')),
      'wrong',
    );
    await tester.tap(find.byKey(const ValueKey('auth-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    expect(authenticated, isFalse);

    repository.signInError = const AuthFailure.connection();
    await tester.tap(find.byKey(const ValueKey('auth-retry')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi lalu coba lagi.',
      ),
      findsOneWidget,
    );

    repository.signInError = null;
    await tester.tap(find.byKey(const ValueKey('auth-retry')));
    await tester.pumpAndSettle();
    expect(repository.signInCalls, 3);
    expect(authenticated, isTrue);

    provider.dispose();
  });

  testWidgets('Google sign-in can be retried after launch failure', (
    WidgetTester tester,
  ) async {
    final repository = FakeAuthRepository()
      ..googleError = const AuthFailure.googleSignInUnavailable();
    final provider = AuthProvider(repository);
    await pumpAuthScreen(tester, provider, onAuthenticated: () {});

    await tester.tap(find.byKey(const ValueKey('auth-google')));
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak dapat membuka login Google. Silakan coba lagi.'),
      findsOneWidget,
    );

    repository.googleError = null;
    await tester.tap(find.byKey(const ValueKey('auth-retry')));
    await tester.pumpAndSettle();
    expect(repository.googleCalls, 2);
    expect(provider.errorMessage, isNull);

    provider.dispose();
  });
}
