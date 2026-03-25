import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../responsive/responsive_extension.dart';

class PhoneViewport extends StatelessWidget {
  const PhoneViewport({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final viewportMaxWidth = maxWidth ?? context.maxContentWidth;
    Widget content = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: child,
    );

    if (viewportMaxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: viewportMaxWidth),
        child: content,
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: content,
      ),
    );
  }
}
