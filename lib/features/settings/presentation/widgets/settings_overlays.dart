import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/models/app_preferences.dart';
import '../viewmodels/app_preferences_controller.dart';

enum DeleteProfileDecision { delete, backupAndDelete }

Future<void> showChooseCurrencySheet(
  BuildContext context,
  AppPreferencesController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.backgroundAlt,
    builder: (context) {
      return _ChoiceSheet(
        title: 'Choose currency',
        children: _supportedCurrencies
            .map((currencyCode) {
              final isSelected = controller.currencyCode == currencyCode;
              return _ChoiceTile(
                label: currencyCode,
                isSelected: isSelected,
                onTap: () async {
                  await controller.updateCurrencyCode(currencyCode);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            })
            .toList(growable: false),
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
    showDragHandle: true,
    backgroundColor: AppColors.backgroundAlt,
    builder: (context) {
      return _ChoiceSheet(
        title: 'Theme mode',
        children: SettingsThemePreference.values
            .map((preference) {
              final isSelected = controller.themePreference == preference;
              return _ChoiceTile(
                label: preference.label,
                isSelected: isSelected,
                onTap: () async {
                  await controller.updateThemePreference(preference);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            })
            .toList(growable: false),
      );
    },
  );
}

Future<DeleteProfileDecision?> showDeleteProfileConfirmationSheet(
  BuildContext context,
) {
  return showModalBottomSheet<DeleteProfileDecision>(
    context: context,
    backgroundColor: AppColors.backgroundAlt,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete profile', style: AppTextStyles.sheetTitle),
            const SizedBox(height: 8),
            const Text(
              'Deleting your profile clears the local profile and subscription data on this device.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  Navigator.of(context).pop(DeleteProfileDecision.delete);
                },
                child: const Text('Yes, delete'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop(DeleteProfileDecision.backupAndDelete);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandGreen,
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.divider),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: AppTextStyles.secondaryButton,
                ),
                child: const Text('Backup & delete'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sheetTitle),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.body),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.brandGreen)
          : null,
      onTap: onTap,
    );
  }
}

const _supportedCurrencies = <String>['NGN', 'USD', 'EUR', 'GBP', 'KES'];
