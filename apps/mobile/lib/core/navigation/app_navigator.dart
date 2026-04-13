import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void redirectToLogin() {
  final state = appNavigatorKey.currentState;
  if (state == null) return;
  state.pushNamedAndRemoveUntil('/login', (route) => false);
}
