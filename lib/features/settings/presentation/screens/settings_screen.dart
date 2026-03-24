import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../subscriptions/presentation/widgets/subscription_feature_widgets.dart';
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
        return SubscriptionShellScaffold(
          destination: SubscriptionPrimaryDestination.settings,
          onHomeTap: () => context.go(AppRoutes.home),
          onSubscriptionsTap: () => context.go(AppRoutes.subscriptions),
          onInsightsTap: () => context.go(AppRoutes.insights),
          onSettingsTap: () => context.go(AppRoutes.settings),
          onAddTap: () => _openAdd(context),
          child: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: viewModel.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    children: [
                      Text('Settings', style: AppTextStyles.sheetTitle),
                      const SizedBox(height: 20),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            viewModel.errorMessage!,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                      _ProfileCard(profile: viewModel.profile),
                      const SizedBox(height: 16),
                      _SettingsGroup(
                        children: [
                          _SettingsTile(
                            icon: Icons.edit_outlined,
                            label: 'Edit Profile',
                            onTap: () => _openEditProfile(context),
                          ),
                          _SettingsTile(
                            icon: Icons.coffee_outlined,
                            label: 'Buy me coffee',
                            onTap: () => _showOfflineLinkNotice(
                              context,
                              'Buy me coffee',
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.attach_money_rounded,
                            label: 'Currency',
                            value: preferences.currencyCode,
                            onTap: () =>
                                showChooseCurrencySheet(context, preferences),
                          ),
                          _SettingsTile(
                            icon: Icons.dark_mode_outlined,
                            label: 'Theme',
                            value: preferences.themePreference.label,
                            onTap: () =>
                                showThemeModeSheet(context, preferences),
                          ),
                          _SettingsTile(
                            icon: Icons.fingerprint_rounded,
                            label: 'Biometrics',
                            value: preferences.biometricsEnabled
                                ? 'Active'
                                : 'Inactive',
                          ),
                          _SettingsTile(
                            icon: Icons.phone_android_rounded,
                            label: 'Transfer to new device',
                            subtitle:
                                'Import from file or start local migration',
                            onTap: () => showImportExistingProfileSheet(
                              context,
                              onImported: () => context.go(AppRoutes.home),
                            ),
                          ),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            label: 'Terms & Condition',
                            onTap: () => context.push(AppRoutes.terms),
                          ),
                          _SettingsTile(
                            icon: Icons.language_outlined,
                            label: 'Creator\'s Website',
                            onTap: () => _showOfflineLinkNotice(
                              context,
                              'Creator\'s Website',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SurfaceCard(
                        radius: 24,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subscription Tracker',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Published by BrandsCode | v1.0.0',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SurfaceCard(
                        radius: 24,
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                          title: Text(
                            'Delete profile',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _handleDeleteProfile(context, viewModel),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final Profile? profile;

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
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.brandSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.brandGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(email, style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 24,
      padding: EdgeInsets.zero,
      child: Column(
        children: children
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index != children.length - 1)
                    const Divider(height: 1, color: AppColors.divider),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.value,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTextStyles.bodyMuted),
      trailing: value != null
          ? Text(value!, style: AppTextStyles.bodyMuted)
          : onTap != null
          ? const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            )
          : null,
      onTap: onTap,
    );
  }
}
