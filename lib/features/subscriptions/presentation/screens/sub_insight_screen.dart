import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/subscription_feature_widgets.dart';

class SubInsightScreen extends StatelessWidget {
  const SubInsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubscriptionShellScaffold(
      destination: SubscriptionPrimaryDestination.insights,
      onHomeTap: () => context.go(AppRoutes.home),
      onSubscriptionsTap: () => context.go(AppRoutes.subscriptions),
      onInsightsTap: () => context.go(AppRoutes.insights),
      onSettingsTap: () => context.go(AppRoutes.settings),
      onAddTap: () => context.push(AppRoutes.newSubscription),
      child: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: const [
            Text('Sub Insight', style: AppTextStyles.screenTitle),
            SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This section is reserved for subscription insights.',
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The bottom navigation route is now wired correctly, but the insight screen design has not been implemented yet.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
