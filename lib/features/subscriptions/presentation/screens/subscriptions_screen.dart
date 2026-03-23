import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/subscriptions_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAdd(BuildContext context) async {
    final didCreate = await context.push<bool>(AppRoutes.newSubscription);
    if (didCreate == true && context.mounted) {
      await context.read<SubscriptionsViewModel>().load(
            displayMode: context.read<SubscriptionsViewModel>().displayMode,
            selectedCategory: context.read<SubscriptionsViewModel>().selectedCategory,
          );
    }
  }

  Future<void> _openDetails(BuildContext context, String subscriptionId) async {
    await context.push<void>(AppRoutes.subscriptionDetails(subscriptionId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionsViewModel>(
      builder: (context, viewModel, _) {
        return SubscriptionShellScaffold(
          destination: SubscriptionPrimaryDestination.subscriptions,
          onHomeTap: () => context.go(AppRoutes.home),
          onSubscriptionsTap: () => context.go(AppRoutes.subscriptions),
          onInsightsTap: () => context.go(AppRoutes.insights),
          onSettingsTap: () => context.go(AppRoutes.settings),
          onAddTap: () => _openAdd(context),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => viewModel.load(
                displayMode: viewModel.displayMode,
                selectedCategory: viewModel.selectedCategory,
                resetSelectedCategory: viewModel.selectedCategory == null,
              ),
              child: _buildBody(context, viewModel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SubscriptionsViewModel viewModel) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Subscriptions', style: AppTextStyles.screenTitle),
            ),
            _ModeToggle(
              isSelected: viewModel.isGridMode,
              activeAssetPath: AppAssets.gridActive,
              inactiveAssetPath: AppAssets.gridInactive,
              onTap: () {
                _searchController.clear();
                viewModel.updateSearchQuery('');
                context.go(AppRoutes.subscriptions);
              },
            ),
            const SizedBox(width: 8),
            _ModeToggle(
              isSelected: viewModel.isListMode,
              activeAssetPath: AppAssets.listActive,
              inactiveAssetPath: AppAssets.listInactive,
              onTap: () {
                if (viewModel.selectedCategory == null) {
                  viewModel.setDisplayMode(SubscriptionDisplayMode.list);
                  context.go(AppRoutes.subscriptionsView(list: true));
                } else {
                  context.go(
                    AppRoutes.categorySubscriptions(
                      viewModel.selectedCategory!.slug,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 22),
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
        if (viewModel.isGridMode)
          _CategoryGrid(viewModel: viewModel)
        else ...[
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SubscriptionFilterChip(
                  label: 'All',
                  count: viewModel.countForCategory(null),
                  isSelected: viewModel.selectedCategory == null,
                  onTap: () {
                    viewModel.selectCategory(null);
                    viewModel.setDisplayMode(SubscriptionDisplayMode.list);
                    context.go(AppRoutes.subscriptionsView(list: true));
                  },
                ),
                const SizedBox(width: 8),
                ...viewModel.filterCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SubscriptionFilterChip(
                      label: category.label,
                      count: viewModel.countForCategory(category),
                      isSelected: viewModel.selectedCategory == category,
                      onTap: () {
                        viewModel.selectCategory(category);
                        context.go(
                          AppRoutes.categorySubscriptions(category.slug),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SubscriptionSearchField(
            controller: _searchController,
            onChanged: viewModel.updateSearchQuery,
          ),
          const SizedBox(height: 20),
          if (viewModel.groupedSubscriptions.isEmpty)
            const EmptyStateCard(
              assetPath: AppAssets.receiptIllustration,
              label: 'No subscriptions found',
            )
          else
            ...viewModel.groupedSubscriptions.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CategoryListSection(
                  category: group.category,
                  subscriptions: group.subscriptions,
                  onTapSubscription: (subscriptionId) =>
                      _openDetails(context, subscriptionId),
                ),
              );
            }),
        ],
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.viewModel,
  });

  final SubscriptionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final summaries = viewModel.categorySummaries;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.27,
      ),
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return InkWell(
          onTap: () => context.go(
            AppRoutes.categorySubscriptions(summary.category.slug),
          ),
          borderRadius: BorderRadius.circular(28),
          child: SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubscriptionCategoryIcon(category: summary.category, size: 22),
                const Spacer(),
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
      },
    );
  }
}

class _CategoryListSection extends StatelessWidget {
  const _CategoryListSection({
    required this.category,
    required this.subscriptions,
    required this.onTapSubscription,
  });

  final SubscriptionCategory category;
  final List<Subscription> subscriptions;
  final ValueChanged<String> onTapSubscription;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SubscriptionCategoryIcon(category: category, size: 14),
            const SizedBox(width: 8),
            Text(category.label, style: AppTextStyles.bodyMuted),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            children: subscriptions.asMap().entries.map((entry) {
              final index = entry.key;
              final subscription = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == subscriptions.length - 1 ? 0 : 8,
                ),
                child: SubscriptionPaymentTile(
                  subscription: subscription,
                  onTap: () => onTapSubscription(subscription.id),
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isSelected,
    required this.activeAssetPath,
    required this.inactiveAssetPath,
    required this.onTap,
  });

  final bool isSelected;
  final String activeAssetPath;
  final String inactiveAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          isSelected ? activeAssetPath : inactiveAssetPath,
          width: 32,
          height: 32,
        ),
      ),
    );
  }
}
