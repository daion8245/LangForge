import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Publishes [AppState] down the tree and rebuilds dependents when it
/// notifies.
///
/// This is the whole state-management story — twenty lines instead of a
/// package we would have to relitigate later. See `docs/architecture.md`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({required AppState state, required super.child, super.key})
    : super(notifier: state);

  /// Reads the state and subscribes to changes.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }

  /// Reads without subscribing — for callbacks that only mutate.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
