import 'package:flutter/widgets.dart';

import 'responsive_breakpoints.dart';
import 'responsive_constraints.dart';
import 'responsive_spacing.dart';

extension ResponsiveExtension on BuildContext {
  ResponsiveBreakpoints get responsiveBreakpoints =>
      ResponsiveBreakpoints.of(this);

  ResponsiveSpacing get responsiveSpacing => ResponsiveSpacing.of(this);

  ResponsiveConstraints get responsiveConstraints =>
      ResponsiveConstraints.of(this);

  bool get isCompact => responsiveBreakpoints.isCompact;

  bool get isRegular => responsiveBreakpoints.isRegular;

  bool get isExpanded => responsiveBreakpoints.isExpanded;

  double get pageHorizontalPadding => responsiveSpacing.pageHorizontal;

  double get overlayHorizontalPadding => responsiveSpacing.overlayHorizontal;

  double get compactGap => responsiveSpacing.compactGap;

  double get sectionGap => responsiveSpacing.sectionGap;

  double get mediumSectionGap => responsiveSpacing.mediumSectionGap;

  double get largeSectionGap => responsiveSpacing.largeSectionGap;

  EdgeInsets pagePadding({double top = 16, double bottom = 0}) {
    return responsiveSpacing.pageInsets(top: top, bottom: bottom);
  }

  EdgeInsets overlayPadding({double top = 24, double bottom = 24}) {
    return responsiveSpacing.overlayInsets(top: top, bottom: bottom);
  }

  EdgeInsets dialogPadding({double vertical = 24}) {
    return responsiveSpacing.dialogInsets(vertical: vertical);
  }

  double? get maxContentWidth => responsiveConstraints.maxContentWidth;

  double? get formContentMaxWidth => responsiveConstraints.formContentMaxWidth;

  double get bottomSheetMaxWidth => responsiveConstraints.bottomSheetMaxWidth;

  double get dialogMaxWidth => responsiveConstraints.dialogMaxWidth;

  double get primaryNavigationMaxWidth =>
      responsiveConstraints.primaryNavigationMaxWidth;

  int get subscriptionGridColumnCount =>
      responsiveConstraints.subscriptionGridColumnCount;
}
