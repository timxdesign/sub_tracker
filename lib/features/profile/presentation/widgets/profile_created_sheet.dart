import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';

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
      color: AppColors.backgroundAlt,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        key: const Key('profile-created-sheet'),
        width: double.infinity,
        height: 260,
        child: Padding(
          padding: const EdgeInsets.only(top: 84),
          child: Column(
            children: [
              SvgPicture.asset(
                AppAssets.checkCircleIcon,
                width: 51.26,
                height: 51.26,
              ),
              const SizedBox(height: 12),
              Text(
                'Profile created',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
