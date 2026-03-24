import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';

class SubscriptionPrimaryNavigationScope extends InheritedWidget {
  const SubscriptionPrimaryNavigationScope({
    super.key,
    required StatefulNavigationShell navigationShell,
    required super.child,
  }) : _navigationShell = navigationShell;

  final StatefulNavigationShell _navigationShell;

  static SubscriptionPrimaryNavigationController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<
          SubscriptionPrimaryNavigationScope
        >();
    return SubscriptionPrimaryNavigationController._(
      context,
      scope?._navigationShell,
    );
  }

  @override
  bool updateShouldNotify(
    covariant SubscriptionPrimaryNavigationScope oldWidget,
  ) {
    return oldWidget._navigationShell != _navigationShell;
  }
}

class SubscriptionPrimaryNavigationController {
  SubscriptionPrimaryNavigationController._(
    this._context,
    this._navigationShell,
  );

  final BuildContext _context;
  final StatefulNavigationShell? _navigationShell;

  void goHome({bool reset = false}) {
    _goBranch(index: 0, fallbackLocation: AppRoutes.home, reset: reset);
  }

  void goSubscriptions({bool reset = false}) {
    _goBranch(
      index: 1,
      fallbackLocation: AppRoutes.subscriptions,
      reset: reset,
    );
  }

  void goInsights({bool reset = false}) {
    _goBranch(index: 2, fallbackLocation: AppRoutes.insights, reset: reset);
  }

  void goSettings({bool reset = false}) {
    _goBranch(index: 3, fallbackLocation: AppRoutes.settings, reset: reset);
  }

  void _goBranch({
    required int index,
    required String fallbackLocation,
    required bool reset,
  }) {
    final navigationShell = _navigationShell;
    if (navigationShell != null) {
      navigationShell.goBranch(index, initialLocation: reset);
      return;
    }

    _context.go(fallbackLocation);
  }
}
