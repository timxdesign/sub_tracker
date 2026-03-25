import 'package:flutter/widgets.dart';

import 'responsive_breakpoints.dart';

class ResponsiveConstraints {
  const ResponsiveConstraints(this.breakpoints);

  factory ResponsiveConstraints.of(BuildContext context) {
    return ResponsiveConstraints(ResponsiveBreakpoints.of(context));
  }

  final ResponsiveBreakpoints breakpoints;

  double? get maxContentWidth => breakpoints.isExpanded ? 720 : null;

  double? get formContentMaxWidth => breakpoints.isExpanded ? 520 : null;

  double get bottomSheetMaxWidth => breakpoints.isExpanded ? 460 : 390;

  double get dialogMaxWidth => breakpoints.isExpanded ? 420 : 360;

  double get primaryNavigationMaxWidth => 336;

  int get subscriptionGridColumnCount => breakpoints.isExpanded ? 3 : 2;
}
