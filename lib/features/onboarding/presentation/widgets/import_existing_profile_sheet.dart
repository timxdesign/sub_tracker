import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';

Future<void> showImportExistingProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    isScrollControlled: true,
    builder: (context) {
      return const _CenteredBottomOverlay(
        child: _ImportExistingProfileSheet(),
      );
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

class _ImportExistingProfileSheet extends StatelessWidget {
  const _ImportExistingProfileSheet();

  void _showNotReadyMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundAlt,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        key: const Key('import-existing-profile-sheet'),
        width: double.infinity,
        height: 533,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16.5, 24, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.36),
                      child: Text(
                        'Import existing profile',
                        style: AppTextStyles.sheetTitle,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: SvgPicture.asset(
                      AppAssets.closeIcon,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17.5),
              _ImportOptionCard(
                height: 209,
                iconAssetPath: AppAssets.importIcon,
                title: 'Import from file',
                description: 'Select export file from device',
                onTap: () => _showNotReadyMessage(
                  context,
                  'File import is not wired yet.',
                ),
              ),
              const SizedBox(height: 15),
              _ImportOptionCard(
                height: 210,
                iconAssetPath: AppAssets.scanQrIcon,
                title: 'Scan QR',
                description:
                    'Go to settings on your old device and migrate with QR.',
                descriptionWidth: 230,
                onTap: () => _showNotReadyMessage(
                  context,
                  'QR migration is not wired yet.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportOptionCard extends StatelessWidget {
  const _ImportOptionCard({
    required this.height,
    required this.iconAssetPath,
    required this.title,
    required this.description,
    required this.onTap,
    this.descriptionWidth,
  });

  final double height;
  final String iconAssetPath;
  final String title;
  final String description;
  final VoidCallback onTap;
  final double? descriptionWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(iconAssetPath, width: 56, height: 56),
                const SizedBox(height: 17),
                Text(
                  title,
                  style: AppTextStyles.optionTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: descriptionWidth,
                  child: Text(
                    description,
                    style: AppTextStyles.optionDescription,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
