import 'package:flutter/widgets.dart';

import 'responsive_breakpoints.dart';

class ResponsiveSpacing {
  const ResponsiveSpacing(this.breakpoints);

  factory ResponsiveSpacing.of(BuildContext context) {
    return ResponsiveSpacing(ResponsiveBreakpoints.of(context));
  }

  final ResponsiveBreakpoints breakpoints;

  double get pageHorizontal {
    switch (breakpoints.sizeClass) {
      case ResponsiveSizeClass.compact:
        return 16;
      case ResponsiveSizeClass.regular:
        return 24;
      case ResponsiveSizeClass.expanded:
        return 28;
    }
  }

  double get overlayHorizontal {
    switch (breakpoints.sizeClass) {
      case ResponsiveSizeClass.compact:
        return 16;
      case ResponsiveSizeClass.regular:
        return 24;
      case ResponsiveSizeClass.expanded:
        return 24;
    }
  }

  double get compactGap => breakpoints.isCompact ? 8 : 12;

  double get sectionGap => breakpoints.isExpanded ? 16 : 12;

  double get mediumSectionGap => breakpoints.isExpanded ? 24 : 22;

  double get largeSectionGap => breakpoints.isExpanded ? 36 : 30;

  double get navigationBottom => breakpoints.isCompact ? 16 : 24;

  EdgeInsets pageInsets({double top = 16, double bottom = 0}) {
    return EdgeInsets.fromLTRB(pageHorizontal, top, pageHorizontal, bottom);
  }

  EdgeInsets overlayInsets({double top = 24, double bottom = 24}) {
    return EdgeInsets.fromLTRB(
      overlayHorizontal,
      top,
      overlayHorizontal,
      bottom,
    );
  }

  EdgeInsets dialogInsets({double vertical = 24}) {
    final horizontal = breakpoints.isCompact ? 16.0 : 24.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }
}
