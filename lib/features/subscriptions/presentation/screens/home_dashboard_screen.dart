import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../settings/presentation/viewmodels/app_preferences_controller.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/home_dashboard_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final didCreate = await context.push<bool>(AppRoutes.newSubscription);
    if (didCreate == true && context.mounted) {
      await context.read<HomeDashboardViewModel>().load();
    }
  }

  Future<void> _openDetails(BuildContext context, String subscriptionId) async {
    await context.push<void>(AppRoutes.subscriptionDetails(subscriptionId));
  }

  void _openCategory(BuildContext context, SubscriptionCategory category) {
    context.go(AppRoutes.categorySubscriptions(category.slug));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDashboardViewModel>(
      builder: (context, viewModel, _) {
        return SubscriptionShellScaffold(
          destination: SubscriptionPrimaryDestination.home,
          onHomeTap: () => context.go(AppRoutes.home),
          onSubscriptionsTap: () => context.go(AppRoutes.subscriptions),
          onInsightsTap: () => context.go(AppRoutes.insights),
          onSettingsTap: () => context.go(AppRoutes.settings),
          onAddTap: () => _openAdd(context),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: viewModel.load,
              child: _buildBody(context, viewModel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeDashboardViewModel viewModel) {
    final categoryPreview = viewModel.categoryPreview;
    final currencyCode =
        context.watch<AppPreferencesController?>()?.currencyCode ?? 'NGN';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        _DashboardHeader(firstName: viewModel.firstName),
        const SizedBox(height: 18),
        if (viewModel.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              viewModel.errorMessage!,
              style: AppTextStyles.bodyMuted,
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                assetPath: AppAssets.checkIllustration,
                assetSize: 30,
                value: formatTwoDigits(viewModel.activeCount),
                label: 'Active',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                assetPath: AppAssets.cancelIllustration,
                assetSize: 25,
                value: formatTwoDigits(viewModel.expiredCount),
                label: 'Expired',
                trailingIcon: const Icon(
                  Icons.info_outline,
                  color: AppColors.error,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Expiring soon',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.darkBadge,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        viewModel.expiringSoonCount.toString(),
                        style: AppTextStyles.smallLabel.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatCurrency(currencyCode, viewModel.expiringSoonTotal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'Subscriptions',
          actionLabel: 'View all',
          onTap: () => context.go(AppRoutes.subscriptions),
        ),
        const SizedBox(height: 14),
        Row(
          children: categoryPreview
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final summary = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 0 ? 8 : 0,
                      left: index == 0 ? 0 : 8,
                    ),
                    child: _CategoryPreviewCard(
                      key: ValueKey(
                        'home-category-preview-${summary.category.slug}',
                      ),
                      summary: summary,
                      onTap: () => _openCategory(context, summary.category),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 22),
        SectionHeader(
          title: 'Upcoming payment',
          actionLabel: 'View all',
          onTap: () => context.push(AppRoutes.upcoming),
        ),
        const SizedBox(height: 14),
        if (viewModel.upcomingPreview.isEmpty)
          const EmptyStateCard(
            assetPath: AppAssets.receiptIllustration,
            label: 'No upcoming payment',
          )
        else
          SurfaceCard(
            child: Column(
              children: viewModel.upcomingPreview
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final subscription = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == viewModel.upcomingPreview.length - 1
                            ? 0
                            : 8,
                      ),
                      child: SubscriptionPaymentTile(
                        subscription: subscription,
                        onTap: () => _openDetails(context, subscription.id),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            firstName.substring(0, 1).toUpperCase(),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Hi, $firstName',
          style: AppTextStyles.body.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.assetPath,
    required this.assetSize,
    required this.value,
    required this.label,
    this.trailingIcon,
  });

  final String assetPath;
  final double assetSize;
  final String value;
  final String label;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      child: SurfaceCard(
        radius: 24,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            if (trailingIcon != null)
              Positioned(
                top: 8,
                right: 8,
                child: SizedBox(width: 16, height: 16, child: trailingIcon),
              ),
            Center(
              child: SizedBox(
                width: 52,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      assetPath,
                      width: assetSize,
                      height: assetSize,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: AppTextStyles.statValue.copyWith(
                            fontSize: 24,
                            height: 29 / 24,
                            letterSpacing: -0.96,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted.copyWith(
                            height: 17 / 14,
                            letterSpacing: -0.14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPreviewCard extends StatelessWidget {
  const _CategoryPreviewCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final DashboardCategoryPreview summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: SurfaceCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubscriptionCategoryIcon(category: summary.category, size: 22),
            const SizedBox(height: 24),
            Text(summary.category.label, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 4),
            Text(
              formatTwoDigits(summary.count),
              style: AppTextStyles.statValue,
            ),
          ],
        ),
      ),
    );
  }
}
