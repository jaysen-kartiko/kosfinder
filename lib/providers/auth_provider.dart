import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> signIn({required String email, required String password}) {
    return _run(
      () => _repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> signUp({required String email, required String password}) {
    return _run(
      () => _repository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> signInWithGoogle() {
    return _run(_repository.signInWithGoogle, successStatus: AuthStatus.idle);
  }

  Future<bool> signOut() {
    return _run(_repository.signOut, successStatus: AuthStatus.idle);
  }

  void clearError() {
    if (isLoading) {
      return;
    }
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(
    Future<void> Function() operation, {
    AuthStatus successStatus = AuthStatus.authenticated,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
      _status = successStatus;
      notifyListeners();
      return true;
    } on AuthFailure catch (failure) {
      _status = AuthStatus.error;
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    } finally {
      if (_status == AuthStatus.loading) {
        _status = AuthStatus.idle;
        notifyListeners();
      }
    }
  }
}
