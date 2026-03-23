import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../domain/models/subscription.dart';
import '../viewmodels/subscription_details_view_model.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionDetailsViewModel>(
      builder: (context, viewModel, _) {
        final subscription = viewModel.subscription;

        return AppScreen(
          appBar: AppBar(title: const Text('Subscription details')),
          child: PhoneViewport(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : subscription == null
                        ? const Center(
                            child: Text(
                              'Subscription not found.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          )
                        : ListView(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subscription.name,
                                      style: AppTextStyles.screenTitle,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      subscription.categoryLabel,
                                      style: AppTextStyles.bodyMuted,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      formatCurrency(
                                        subscription.currencyCode,
                                        subscription.price,
                                      ),
                                      style: AppTextStyles.subscriptionAmount,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${subscription.billingCycle.label} plan',
                                      style: AppTextStyles.bodyMuted,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _DetailTile(
                                label: 'Next billing date',
                                value: formatShortDate(
                                  subscription.nextBillingDate,
                                ),
                              ),
                              _DetailTile(
                                label: 'Monthly equivalent',
                                value: formatCurrency(
                                  subscription.currencyCode,
                                  subscription.monthlyCost,
                                ),
                              ),
                              _DetailTile(
                                label: 'Notes',
                                value: subscription.description.isEmpty
                                    ? 'No additional notes'
                                    : subscription.description,
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
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
