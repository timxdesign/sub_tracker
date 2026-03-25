import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../../subscriptions/presentation/widgets/subscription_feature_widgets.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: PhoneViewport(
        child: SafeArea(
          child: Column(
            children: [
              const _TermsHeader(),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.formContentMaxWidth ?? double.infinity,
                    ),
                    child: ListView(
                      padding: context.pagePadding(top: 26, bottom: 32),
                      children: [
                        SurfaceCard(
                          radius: 24,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _sections
                                .map(
                                  (section) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          section == _sections.last ? 0 : 16,
                                    ),
                                    child: _TermsSection(section: section),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
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

class _TermsHeader extends StatelessWidget {
  const _TermsHeader();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;
    return Container(
      height: 64,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: horizontalPadding,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(999),
              child: Ink(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Text(
            'Terms & Condition',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 20,
              height: 28 / 20,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.section});

  final _TermsContent section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            height: 28 / 20,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          section.body,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _TermsContent {
  const _TermsContent({required this.title, required this.body});

  final String title;
  final String body;
}

const _sections = <_TermsContent>[
  _TermsContent(
    title: '1. Use of the App',
    body:
        'Subscription Tracker is designed to help you manage and track your subscriptions. You agree to use the app only for lawful purposes and in a way that does not harm the app or other users.',
  ),
  _TermsContent(
    title: '2. User Data',
    body:
        'You are responsible for the accuracy of any information you enter into the app. The app stores your subscription data locally on your device unless otherwise stated.',
  ),
  _TermsContent(
    title: '3. No Financial Advice',
    body:
        'Subscription Tracker does not provide financial, investment, or legal advice. All insights and calculations are for informational purposes only.',
  ),
  _TermsContent(
    title: '4. Availability',
    body:
        'We aim to keep the app running smoothly, but we do not guarantee uninterrupted access. Features may be updated, modified, or removed at any time.',
  ),
  _TermsContent(
    title: '5. Limitation of Liability',
    body:
        'We are not responsible for any loss, damage, or missed payments resulting from the use of the app. You are solely responsible for managing your subscriptions and payments.',
  ),
  _TermsContent(
    title: '6. Privacy',
    body:
        'Your privacy matters. Any personal information collected will be handled in accordance with our Privacy Policy.',
  ),
  _TermsContent(
    title: '7. Changes to Terms',
    body:
        'We may update these terms from time to time. Continued use of the app means you accept any changes.',
  ),
  _TermsContent(
    title: '8. Contact',
    body: 'If you have any questions, contact us at:\nexodustimothy@gmail.com',
  ),
];
