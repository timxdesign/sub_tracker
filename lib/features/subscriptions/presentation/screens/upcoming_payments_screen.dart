import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../viewmodels/upcoming_payments_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';

class UpcomingPaymentsScreen extends StatelessWidget {
  const UpcomingPaymentsScreen({super.key});

  Future<void> _openDetails(BuildContext context, String subscriptionId) async {
    await context.push<void>(AppRoutes.subscriptionDetails(subscriptionId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpcomingPaymentsViewModel>(
      builder: (context, viewModel, _) {
        return AppScreen(
          backgroundColor: AppColors.background,
          child: PhoneViewport(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding(top: 16, bottom: 32),
                  children: [
                    Row(
                      children: [
                        InkResponse(
                          onTap: () => context.pop(),
                          radius: 22,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceMuted,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Upcoming Payment',
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                        ),
                        SizedBox(width: context.isCompact ? 24 : 32),
                      ],
                    ),
                    SizedBox(height: context.mediumSectionGap + 2),
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (viewModel.payments.isEmpty)
                      const EmptyStateCard(
                        assetPath: AppAssets.receiptIllustration,
                        label: 'No upcoming payment',
                      )
                    else
                      SurfaceCard(
                        child: Column(
                          children: viewModel.payments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final payment = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == viewModel.payments.length - 1
                                    ? 0
                                    : 8,
                              ),
                              child: SubscriptionPaymentTile(
                                subscription: payment,
                                onTap: () => _openDetails(context, payment.id),
                              ),
                            );
                          }).toList(growable: false),
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
}
