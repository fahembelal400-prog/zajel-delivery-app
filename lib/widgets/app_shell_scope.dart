import 'package:flutter/material.dart';

class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.selectTab,
    required super.child,
  });

  final void Function(int index) selectTab;

  void goToHome() => selectTab(0);

  void goToOrders() => selectTab(1);

  void goToAccount() => selectTab(2);

  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }

  static AppShellScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'AppShellScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => false;
}
