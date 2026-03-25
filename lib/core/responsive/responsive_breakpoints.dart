import 'package:flutter/widgets.dart';

enum ResponsiveSizeClass { compact, regular, expanded }

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._(this.width);

  factory ResponsiveBreakpoints.of(BuildContext context) {
    return ResponsiveBreakpoints.fromWidth(MediaQuery.sizeOf(context).width);
  }

  factory ResponsiveBreakpoints.fromWidth(double width) {
    return ResponsiveBreakpoints._(width);
  }

  static const double compactMaxWidth = 360;
  static const double expandedMinWidth = 600;

  final double width;

  ResponsiveSizeClass get sizeClass {
    if (isCompact) {
      return ResponsiveSizeClass.compact;
    }
    if (isExpanded) {
      return ResponsiveSizeClass.expanded;
    }
    return ResponsiveSizeClass.regular;
  }

  bool get isCompact => width < compactMaxWidth;

  bool get isRegular => width >= compactMaxWidth && width < expandedMinWidth;

  bool get isExpanded => width >= expandedMinWidth;
}
