import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailureKind {
  invalidCredentials,
  emailAlreadyRegistered,
  connection,
  emailConfirmationRequired,
  googleSignInUnavailable,
  other,
}

const googleOAuthRedirectUrl = 'io.supabase.kosfinder://login-callback/';

class AuthFailure implements Exception {
  const AuthFailure({required this.message, required this.kind});

  const AuthFailure.invalidCredentials()
    : this(
        message: 'Email atau kata sandi salah.',
        kind: AuthFailureKind.invalidCredentials,
      );

  const AuthFailure.emailAlreadyRegistered()
    : this(
        message: 'Email sudah terdaftar. Silakan masuk.',
        kind: AuthFailureKind.emailAlreadyRegistered,
      );

  const AuthFailure.connection()
    : this(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
        kind: AuthFailureKind.connection,
      );

  const AuthFailure.emailConfirmationRequired()
    : this(
        message: 'Sesi login tidak tersedia. Nonaktifkan konfirmasi email di pengaturan Supabase Auth.',
        kind: AuthFailureKind.emailConfirmationRequired,
      );

  const AuthFailure.googleSignInUnavailable()
    : this(
        message: 'Tidak dapat membuka login Google. Silakan coba lagi.',
        kind: AuthFailureKind.googleSignInUnavailable,
      );

  final String message;
  final AuthFailureKind kind;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const AuthFailure.invalidCredentials();
      }
    } on AuthFailure {
      rethrow;
    } on AuthRetryableFetchException {
      throw const AuthFailure.connection();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const AuthFailure.emailConfirmationRequired();
      }
    } on AuthFailure {
      rethrow;
    } on AuthRetryableFetchException {
      throw const AuthFailure.connection();
    } on PlatformException {
      throw const AuthFailure.googleSignInUnavailable();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: googleOAuthRedirectUrl,
      );
      if (!launched) {
        throw const AuthFailure.googleSignInUnavailable();
      }
    } on AuthFailure {
      rethrow;
    } on AuthRetryableFetchException {
      throw const AuthFailure.connection();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthRetryableFetchException {
      throw const AuthFailure.connection();
    } on PlatformException {
      throw const AuthFailure.connection();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  AuthFailure _mapAuthException(AuthException error) {
    final code = error.code?.toLowerCase();
    if (code == 'invalid_credentials' ||
        error.message.toLowerCase().contains('invalid login credentials')) {
      return const AuthFailure.invalidCredentials();
    }
    if (code == 'user_already_exists' || code == 'email_exists') {
      return const AuthFailure.emailAlreadyRegistered();
    }
    if (error.statusCode == null) {
      return const AuthFailure.connection();
    }
    return AuthFailure(
      message: 'Autentikasi gagal: ${error.message}',
      kind: AuthFailureKind.other,
    );
  }
}
