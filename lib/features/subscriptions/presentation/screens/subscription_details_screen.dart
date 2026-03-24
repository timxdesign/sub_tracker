import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/subscription_details_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';

enum _SubscriptionDetailsTab { info, summary }

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  _SubscriptionDetailsTab _selectedTab = _SubscriptionDetailsTab.info;

  Future<void> _handleRenew(SubscriptionDetailsViewModel viewModel) async {
    final previousDate = viewModel.subscription?.nextBillingDate;
    await viewModel.renew();
    if (!mounted || previousDate == null) {
      return;
    }

    final updatedDate = viewModel.subscription?.nextBillingDate;
    if (updatedDate != null && !updatedDate.isAtSameMomentAs(previousDate)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subscription renewed')));
    }
  }

  void _showEditNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit subscription is not available yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionDetailsViewModel>(
      builder: (context, viewModel, _) {
        final subscription = viewModel.subscription;

        return AppScreen(
          backgroundColor: AppColors.background,
          child: PhoneViewport(
            child: SafeArea(
              bottom: false,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: Row(
                        children: [
                          Text(
                            'Details',
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 20,
                              height: 28 / 20,
                              letterSpacing: -1,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(999),
                            child: Ink(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppAssets.closeIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DetailsTabButton(
                              label: 'Info',
                              isSelected:
                                  _selectedTab == _SubscriptionDetailsTab.info,
                              onTap: () {
                                setState(() {
                                  _selectedTab = _SubscriptionDetailsTab.info;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _DetailsTabButton(
                              label: 'Summary',
                              isSelected:
                                  _selectedTab ==
                                  _SubscriptionDetailsTab.summary,
                              onTap: () {
                                setState(() {
                                  _selectedTab =
                                      _SubscriptionDetailsTab.summary;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (viewModel.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (subscription == null) {
                            return const Center(
                              child: Text(
                                'Subscription not found.',
                                style: AppTextStyles.bodyMuted,
                              ),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                            children: [
                              if (_selectedTab ==
                                      _SubscriptionDetailsTab.info &&
                                  _showsRenewAction(subscription)) ...[
                                SizedBox(
                                  height: 56,
                                  child: FilledButton(
                                    onPressed: viewModel.isUpdating
                                        ? null
                                        : () => _handleRenew(viewModel),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.brandGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: viewModel.isUpdating
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                AppAssets.checkCircleIcon,
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'I have renewed',
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      letterSpacing: -0.2,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              SurfaceCard(
                                radius: 24,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SubscriptionBrandAvatar(
                                      subscriptionName: subscription.name,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      subscription.name,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.sectionTitle
                                          .copyWith(
                                            fontSize: 20,
                                            height: 28 / 20,
                                            letterSpacing: -1,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_selectedTab == _SubscriptionDetailsTab.info)
                                ..._buildInfoContent(subscription)
                              else
                                _SummaryCard(subscription: subscription),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildInfoContent(Subscription subscription) {
    return [
      SurfaceCard(
        radius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _DetailsInfoRow(
              label: 'Status',
              value: _StatusPill(status: subscription.renewalStatus),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Billing cycle',
              value: _DetailsPill(label: subscription.billingCycle.label),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Start date',
              value: _DetailsValueText(
                label: _formatCompactDate(subscription.effectiveStartDate),
              ),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Next billing date',
              value: _DetailsValueText(
                label: _formatLongMonthDate(subscription.nextBillingDate),
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Category',
              value: _DetailsPill(label: subscription.categoryLabel),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Service Provider',
              value: _optionalPill(subscription.serviceProvider),
            ),
            const SizedBox(height: 16),
            _DetailsInfoRow(
              label: 'Website',
              value: _optionalPill(subscription.website),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _DetailsActionButton(
              label: 'Edit',
              icon: Icons.edit_outlined,
              foregroundColor: AppColors.textPrimary,
              backgroundColor: Colors.white,
              onTap: _showEditNotice,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DetailsActionButton(
              label: 'Cancel',
              icon: Icons.cancel_outlined,
              foregroundColor: AppColors.error,
              backgroundColor: const Color(0x1AFF4842),
              onTap: () => context.pop(),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _optionalPill(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const _DetailsValueText(
        label: 'Not added',
        color: AppColors.textTertiary,
      );
    }

    return _DetailsPill(label: trimmed);
  }

  bool _showsRenewAction(Subscription subscription) {
    return subscription.expiresToday || subscription.isExpired;
  }
}

class _DetailsTabButton extends StatelessWidget {
  const _DetailsTabButton({
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.brandGreen : AppColors.divider,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.16,
            color: isSelected ? AppColors.brandGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DetailsInfoRow extends StatelessWidget {
  const _DetailsInfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(width: 16),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: value),
        ),
      ],
    );
  }
}

class _DetailsPill extends StatelessWidget {
  const _DetailsPill({
    required this.label,
    this.backgroundColor = AppColors.surfaceMuted,
    this.foregroundColor = AppColors.textPrimary,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMuted.copyWith(
            color: foregroundColor,
            height: 1.2,
            letterSpacing: -0.14,
          ),
        ),
      ),
    );
  }
}

class _DetailsValueText extends StatelessWidget {
  const _DetailsValueText({
    required this.label,
    this.color = AppColors.textPrimary,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.right,
      style: AppTextStyles.bodyMuted.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SubscriptionRenewalStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color backgroundColor;
    late final Color foregroundColor;

    switch (status) {
      case SubscriptionRenewalStatus.active:
        label = 'Active';
        backgroundColor = const Color(0xFFE9FCD4);
        foregroundColor = const Color(0xFF54D62C);
        break;
      case SubscriptionRenewalStatus.expiringSoon:
        label = 'Expiring Soon';
        backgroundColor = const Color(0xFFFFF5CC);
        foregroundColor = const Color(0xFFFFAB00);
        break;
      case SubscriptionRenewalStatus.expiresToday:
        label = 'Expires Today';
        backgroundColor = const Color(0xFFFFF5CC);
        foregroundColor = const Color(0xFFFFAB00);
        break;
      case SubscriptionRenewalStatus.expired:
        label = 'Expired';
        backgroundColor = const Color(0xFFFFE9E8);
        foregroundColor = AppColors.error;
        break;
    }

    return _DetailsPill(
      label: label,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _DetailsActionButton extends StatelessWidget {
  const _DetailsActionButton({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: foregroundColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: foregroundColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            formatCurrency(
              subscription.currencyCode,
              subscription.totalAmountSpent,
            ),
            style: AppTextStyles.screenTitle.copyWith(
              color: const Color(0xFF54D62C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total amount spent',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCompactDate(DateTime date) {
  const months = <String>[
    'Jan.',
    'Feb.',
    'Mar.',
    'Apr.',
    'May',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sept.',
    'Oct.',
    'Nov.',
    'Dec.',
  ];

  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}

String _formatLongMonthDate(DateTime date) {
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${date.day} ${months[date.month - 1]}, ${date.year}';
}
