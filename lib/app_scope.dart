// Intellectual property of Strauch Development. All rights reserved.
import 'package:flutter/widgets.dart';

import 'app_controller.dart';

/// Exposes the [AppController] to the widget tree and rebuilds dependents
/// whenever it notifies.
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context.');
    return scope!.notifier!;
  }
}
