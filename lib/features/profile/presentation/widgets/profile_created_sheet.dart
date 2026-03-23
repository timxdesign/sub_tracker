import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

Future<void> showProfileCreatedSheet(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  unawaited(
    Future<void>.delayed(const Duration(milliseconds: 1350), () {
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
    }),
  );

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    isDismissible: false,
    enableDrag: false,
    builder: (context) {
      return const _CenteredBottomOverlay(child: _ProfileCreatedSheet());
    },
  );
}

class _CenteredBottomOverlay extends StatelessWidget {
  const _CenteredBottomOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: child,
      ),
    );
  }
}

class _ProfileCreatedSheet extends StatelessWidget {
  const _ProfileCreatedSheet();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: 260,
        child: Padding(
          padding: const EdgeInsets.only(top: 84),
          child: Column(
            children: [
              Container(
                width: 39.26,
                height: 39.26,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Profile created',
                style: AppTextStyles.successLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
