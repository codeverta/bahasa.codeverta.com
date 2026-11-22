import 'package:flutter/widgets.dart';

class AuthGate extends InheritedWidget {
  const AuthGate({required this.authorize, required super.child, super.key});

  final Future<bool> Function() authorize;

  static Future<bool> requireLogin(BuildContext context) {
    final gate = context.dependOnInheritedWidgetOfExactType<AuthGate>();
    assert(gate != null, 'AuthGate was not found in the widget tree');
    return gate!.authorize();
  }

  @override
  bool updateShouldNotify(AuthGate oldWidget) =>
      authorize != oldWidget.authorize;
}
