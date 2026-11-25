import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.provider,
    required this.onAuthenticated,
  });

  final AuthProvider provider;
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _retryGoogleSignIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.provider.isLoading || !_formKey.currentState!.validate()) {
      return;
    }
    _retryGoogleSignIn = false;

    final authenticated = _isRegistering
        ? await widget.provider.signUp(
            email: _emailController.text,
            password: _passwordController.text,
          )
        : await widget.provider.signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
    if (authenticated && mounted) {
      widget.onAuthenticated();
    }
  }

  Future<void> _signInWithGoogle() async {
    if (widget.provider.isLoading) {
      return;
    }
    _retryGoogleSignIn = true;
    await widget.provider.signInWithGoogle();
  }

  Future<void> _retry() {
    return _retryGoogleSignIn ? _signInWithGoogle() : _submit();
  }

  void _toggleMode() {
    widget.provider.clearError();
    setState(() {
      _isRegistering = !_isRegistering;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KosFinder')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: AnimatedBuilder(
                animation: widget.provider,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegistering ? 'Buat akun' : 'Masuk',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const ValueKey('auth-email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('auth-password'),
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Kata sandi',
                      ),
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (widget.provider.errorMessage case final message?)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              message,
                              key: const ValueKey('auth-error'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              key: const ValueKey('auth-retry'),
                              onPressed: widget.provider.isLoading
                                  ? null
                                  : _retry,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('auth-submit'),
                      onPressed: widget.provider.isLoading ? null : _submit,
                      child: widget.provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegistering ? 'Daftar' : 'Masuk'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('atau', textAlign: TextAlign.center),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('auth-google'),
                      onPressed: widget.provider.isLoading
                          ? null
                          : _signInWithGoogle,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: const Text('Lanjutkan dengan Google'),
                    ),
                    TextButton(
                      onPressed: widget.provider.isLoading ? null : _toggleMode,
                      child: Text(
                        _isRegistering
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan format email yang valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    return null;
  }
}
