import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../subscriptions/presentation/widgets/subscription_feature_widgets.dart';
import '../../../subscriptions/presentation/widgets/subscription_primary_navigation.dart';
import '../../domain/models/app_preferences.dart';
import '../viewmodels/app_preferences_controller.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/import_existing_profile_sheet.dart';
import '../widgets/settings_overlays.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    await context.push(AppRoutes.newSubscription);
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final didUpdate = await context.push<bool>(AppRoutes.editProfile);
    if (didUpdate == true && context.mounted) {
      await context.read<SettingsViewModel>().load();
    }
  }

  Future<void> _handleDeleteProfile(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final decision = await showDeleteProfileConfirmationSheet(context);
    if (!context.mounted || decision == null) {
      return;
    }

    final result = switch (decision) {
      DeleteProfileDecision.delete => await viewModel.deleteProfile(),
      DeleteProfileDecision.backupAndDelete =>
        await viewModel.backupAndDeleteProfile(),
    };

    if (!context.mounted) {
      return;
    }

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Action failed.')),
      );
      return;
    }

    await context.read<AppPreferencesController>().reload();
    if (!context.mounted) {
      return;
    }

    if (result.backupPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup exported to ${result.backupPath}')),
      );
    }

    context.go(AppRoutes.createProfile);
  }

  void _showOfflineLinkNotice(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label is not available offline in this build.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsViewModel, AppPreferencesController>(
      builder: (context, viewModel, preferences, _) {
        final primaryNavigation = SubscriptionPrimaryNavigationScope.of(
          context,
        );
        return SubscriptionShellScaffold(
          destination: SubscriptionPrimaryDestination.settings,
          onHomeTap: () => primaryNavigation.goHome(),
          onSubscriptionsTap: () => primaryNavigation.goSubscriptions(),
          onInsightsTap: () => primaryNavigation.goInsights(),
          onSettingsTap: () => primaryNavigation.goSettings(),
          onAddTap: () => _openAdd(context),
          child: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding(top: 16, bottom: 140),
                    children: [
                      Text('Settings', style: AppTextStyles.sheetTitle),
                      SizedBox(height: context.largeSectionGap + 1),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            viewModel.errorMessage!,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                      _ProfileSummaryCard(
                        profile: viewModel.profile,
                        onEdit: () => _openEditProfile(context),
                      ),
                      SizedBox(height: context.sectionGap + 4),
                      _CenteredActionCard(
                        label: 'Buy me coffee',
                        icon: Icons.coffee_outlined,
                        iconColor: const Color(0xFFA14F28),
                        onTap: () =>
                            _showOfflineLinkNotice(context, 'Buy me coffee'),
                      ),
                      SizedBox(height: context.sectionGap + 4),
                      const _SectionLabel(label: 'Preference'),
                      SizedBox(height: context.sectionGap),
                      _SettingsSectionCard(
                        rows: [
                          _SettingsRow(
                            label: 'Currency',
                            valueLabel: _currencyLabel(
                              preferences.currencyCode,
                            ),
                            onTap: () =>
                                showChooseCurrencySheet(context, preferences),
                          ),
                          _SettingsRow(
                            label: 'Theme',
                            valueLabel: _themeLabel(
                              preferences.themePreference,
                            ),
                            onTap: () =>
                                showThemeModeSheet(context, preferences),
                          ),
                        ],
                      ),
                      SizedBox(height: context.sectionGap + 4),
                      const _SectionLabel(label: 'Date & Security'),
                      SizedBox(height: context.sectionGap),
                      _SettingsSectionCard(
                        rows: [
                          _SettingsRow(
                            label: 'Enable Biometrics',
                            valueLabel: preferences.biometricsEnabled
                                ? 'Active'
                                : 'Inactive',
                            onTap: () => _showOfflineLinkNotice(
                              context,
                              'Biometrics settings',
                            ),
                          ),
                          _SettingsRow(
                            label: 'Transfer to new device',
                            valueLabel: 'Migrate',
                            onTap: () => showImportExistingProfileSheet(
                              context,
                              onImported: () => primaryNavigation.goHome(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.sectionGap + 4),
                      const _SectionLabel(label: 'Legal'),
                      SizedBox(height: context.sectionGap),
                      _SettingsSectionCard(
                        rows: [
                          _SettingsRow(
                            label: 'Terms & Condition',
                            valueLabel: 'Visit',
                            onTap: () => context.push(AppRoutes.terms),
                          ),
                          _SettingsRow(
                            label: 'Creator\'s Website',
                            valueLabel: 'Visit',
                            onTap: () => _showOfflineLinkNotice(
                              context,
                              'Creator\'s Website',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.sectionGap + 4),
                      const _SectionLabel(label: 'App'),
                      SizedBox(height: context.sectionGap),
                      const _SettingsSectionCard(
                        rows: [
                          _SettingsRow(
                            label: 'Version',
                            valueLabel: 'v1.0',
                            showChevron: false,
                            pillBackgroundColor: AppColors.background,
                          ),
                          _SettingsRow(
                            label: 'Publish by',
                            valueLabel: 'TimX Design Studio',
                            showChevron: false,
                            pillBackgroundColor: AppColors.background,
                          ),
                        ],
                      ),
                      SizedBox(height: context.largeSectionGap + 2),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              _handleDeleteProfile(context, viewModel),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: AppTextStyles.bodyMuted,
                          ),
                          child: const Text('Delete profile'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (viewModel.isPerformingAction)
                  Positioned.fill(
                    child: ColoredBox(
                      color: const Color(0x1A000000),
                      child: Center(
                        child: SurfaceCard(
                          radius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text(
                                'Processing...',
                                style: AppTextStyles.bodyMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile, required this.onEdit});

  final Profile? profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final fullName = profile?.fullName ?? 'No profile';
    final email = profile?.email ?? 'Create or import a profile';
    final initials = fullName.trim().isEmpty
        ? '?'
        : fullName
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part.substring(0, 1).toUpperCase())
              .join();

    return SurfaceCard(
      radius: 16,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 188,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: AppColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextStyles.smallLabel.copyWith(
                    color: AppColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                fullName,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 20,
                  height: 28 / 20,
                  letterSpacing: -1,
                ),
              ),
              Text(email, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 10),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 134,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      'Edit Profile',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredActionCard extends StatelessWidget {
  const _CenteredActionCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMuted.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final row = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == rows.length - 1 ? 0 : 16,
                ),
                child: row,
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.valueLabel,
    this.onTap,
    this.showChevron = true,
    this.pillBackgroundColor = AppColors.surfaceMuted,
  });

  final String label;
  final String valueLabel;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color pillBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ValuePill(label: valueLabel, backgroundColor: pillBackgroundColor),
          if (showChevron) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMuted.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

String _currencyLabel(String currencyCode) {
  switch (currencyCode) {
    case 'NGN':
      return 'Naira';
    case 'USD':
      return 'Dollars';
    default:
      return currencyCode;
  }
}

String _themeLabel(SettingsThemePreference preference) {
  switch (preference) {
    case SettingsThemePreference.system:
      return 'Auto';
    case SettingsThemePreference.light:
      return 'Light Mode';
    case SettingsThemePreference.dark:
      return 'Dark mode';
  }
}
