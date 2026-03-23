import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PhoneViewport extends StatelessWidget {
  const PhoneViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
