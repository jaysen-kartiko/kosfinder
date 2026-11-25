import 'dart:async';

import 'package:flutter/material.dart';

class AuthSessionGate extends StatefulWidget {
  const AuthSessionGate({
    super.key,
    required this.initiallyAuthenticated,
    required this.sessionChanges,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
  });

  final bool initiallyAuthenticated;
  final Stream<bool> sessionChanges;
  final WidgetBuilder authenticatedBuilder;
  final Widget Function(BuildContext context, VoidCallback onAuthenticated)
  unauthenticatedBuilder;

  @override
  State<AuthSessionGate> createState() => _AuthSessionGateState();
}

class _AuthSessionGateState extends State<AuthSessionGate> {
  late bool _isAuthenticated;
  late StreamSubscription<bool> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.initiallyAuthenticated;
    _sessionSubscription = widget.sessionChanges.listen(_handleSessionChange);
  }

  @override
  void didUpdateWidget(AuthSessionGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessionChanges != oldWidget.sessionChanges) {
      unawaited(_sessionSubscription.cancel());
      _sessionSubscription = widget.sessionChanges.listen(_handleSessionChange);
    }
  }

  void _handleSessionChange(bool authenticated) {
    if (mounted && authenticated != _isAuthenticated) {
      setState(() {
        _isAuthenticated = authenticated;
      });
    }
  }

  void _markAuthenticated() {
    _handleSessionChange(true);
  }

  @override
  void dispose() {
    unawaited(_sessionSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.authenticatedBuilder(context);
    }
    return widget.unauthenticatedBuilder(context, _markAuthenticated);
  }
}
