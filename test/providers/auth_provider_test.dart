import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  Object? signInError;
  Object? signUpError;
  Object? googleError;
  Object? signOutError;
  int signInCalls = 0;
  int signUpCalls = 0;
  int googleCalls = 0;
  int signOutCalls = 0;

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
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError case final error?) {
      throw error;
    }
  }
}

void main() {
  test('valid email-password login and registration authenticate', () async {
    final repository = FakeAuthRepository();
    final provider = AuthProvider(repository);

    expect(
      await provider.signIn(email: 'user@example.com', password: 'pass123'),
      isTrue,
    );
    expect(provider.status, AuthStatus.authenticated);

    expect(
      await provider.signUp(email: 'new@example.com', password: 'pass123'),
      isTrue,
    );
    expect(provider.status, AuthStatus.authenticated);

    expect(await provider.signInWithGoogle(), isTrue);
    expect(provider.status, AuthStatus.idle);
    expect(await provider.signOut(), isTrue);
    expect(provider.status, AuthStatus.idle);

    expect(repository.signInCalls, 1);
    expect(repository.signUpCalls, 1);
    expect(repository.googleCalls, 1);
    expect(repository.signOutCalls, 1);

    provider.dispose();
  });

  test(
    'provider reports invalid credentials and connection failures',
    () async {
      final repository = FakeAuthRepository()
        ..signInError = const AuthFailure.invalidCredentials();
      final provider = AuthProvider(repository);

      expect(
        await provider.signIn(email: 'user@example.com', password: 'wrong'),
        isFalse,
      );
      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, 'Email atau kata sandi salah.');

      provider.clearError();
      repository.signInError = const AuthFailure.connection();
      expect(
        await provider.signIn(email: 'user@example.com', password: 'pass123'),
        isFalse,
      );
      expect(provider.errorMessage, contains('coba lagi'));

      provider.dispose();
    },
  );

  test('provider reports Google launch failures and can start again', () async {
    final repository = FakeAuthRepository()
      ..googleError = const AuthFailure.googleSignInUnavailable();
    final provider = AuthProvider(repository);

    expect(await provider.signInWithGoogle(), isFalse);
    expect(provider.errorMessage, contains('login Google'));

    provider.clearError();
    repository.googleError = null;
    expect(await provider.signInWithGoogle(), isTrue);
    expect(repository.googleCalls, 2);

    provider.dispose();
  });
}
