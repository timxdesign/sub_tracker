import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/models/app_preferences.dart';
import '../viewmodels/app_preferences_controller.dart';

enum DeleteProfileDecision { delete, backupAndDelete }

Future<void> showChooseCurrencySheet(
  BuildContext context,
  AppPreferencesController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    builder: (context) {
      return _BottomOverlayShell(
        height: 218,
        title: 'Choose Currency',
        bodyPadding: const EdgeInsets.fromLTRB(24, 76, 24, 36),
        child: Column(
          children: [
            _SelectionOption(
              label: 'Naira (N)',
              isSelected: controller.currencyCode == 'NGN',
              onTap: () async {
                await controller.updateCurrencyCode('NGN');
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 10),
            _SelectionOption(
              label: 'Dollars (\$)',
              isSelected: controller.currencyCode == 'USD',
              onTap: () async {
                await controller.updateCurrencyCode('USD');
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showThemeModeSheet(
  BuildContext context,
  AppPreferencesController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    builder: (context) {
      return _BottomOverlayShell(
        height: 281,
        title: 'Theme mode',
        bodyPadding: const EdgeInsets.fromLTRB(24, 76, 24, 41),
        child: Column(
          children: SettingsThemePreference.values
              .map((preference) {
                final label = switch (preference) {
                  SettingsThemePreference.system => 'Auto',
                  SettingsThemePreference.light => 'Light mode',
                  SettingsThemePreference.dark => 'Dark mode',
                };
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: preference == SettingsThemePreference.dark ? 0 : 10,
                  ),
                  child: _SelectionOption(
                    label: label,
                    isSelected: controller.themePreference == preference,
                    onTap: () async {
                      await controller.updateThemePreference(preference);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              })
              .toList(growable: false),
        ),
      );
    },
  );
}

Future<DeleteProfileDecision?> showDeleteProfileConfirmationSheet(
  BuildContext context,
) {
  return showModalBottomSheet<DeleteProfileDecision>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlayScrim,
    builder: (context) {
      return _BottomOverlayShell(
        height: 459,
        title: 'Delete Profile?',
        bodyPadding: const EdgeInsets.fromLTRB(24, 74, 24, 36),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE7D9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 24,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      'This action is irreversible',
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 20,
                        height: 28 / 20,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 226,
                      child: Text(
                        'Are you sure you want to delete your profile?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _OverlayActionButton(
              label: 'Yes, delete',
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.of(context).pop(DeleteProfileDecision.delete);
              },
            ),
            const SizedBox(height: 12),
            _OverlayActionButton(
              label: 'Backup & delete',
              backgroundColor: AppColors.surfaceMuted,
              foregroundColor: AppColors.textSecondary,
              onTap: () {
                Navigator.of(
                  context,
                ).pop(DeleteProfileDecision.backupAndDelete);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _BottomOverlayShell extends StatelessWidget {
  const _BottomOverlayShell({
    required this.height,
    required this.title,
    required this.bodyPadding,
    required this.child,
  });

  final double height;
  final String title;
  final EdgeInsets bodyPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Material(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              children: [
                Positioned(
                  left: 24,
                  top: 24,
                  child: Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 20,
                      height: 28 / 20,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: _OverlayCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned.fill(
                  child: Padding(padding: bodyPadding, child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayCloseButton extends StatelessWidget {
  const _OverlayCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(AppAssets.closeIcon, width: 20, height: 20),
        ),
      ),
    );
  }
}

class _SelectionOption extends StatelessWidget {
  const _SelectionOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(33),
      child: Ink(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.16,
              color: isSelected ? AppColors.brandGreen : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: foregroundColor,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
