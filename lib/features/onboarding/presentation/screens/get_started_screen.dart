import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../../settings/presentation/widgets/import_existing_profile_sheet.dart';
import '../viewmodels/get_started_view_model.dart';
import '../widgets/animated_showcase_section.dart';
import '../widgets/dashed_divider.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  static const _contentHeightBeforeButtons = 570.73;
  static const _buttonsBlockHeight = 124.0;

  Future<void> _handleGetStarted(BuildContext context) async {
    await context.read<GetStartedViewModel>().start();
    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.createProfile);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: PhoneViewport(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = math.max(
                0.0,
                constraints.maxHeight - 78.5,
              );
              final buttonSpacing = math.max(
                28.0,
                availableHeight -
                    _contentHeightBeforeButtons -
                    _buttonsBlockHeight,
              );

              return SingleChildScrollView(
                padding: context.pagePadding(top: 54.5, bottom: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight,
                    maxWidth: context.formContentMaxWidth ?? double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 342),
                        child: AnimatedShowcaseSection(
                          cardAssets: AppAssets.onboardingCards,
                          logoAssets: AppAssets.onboardingLogos,
                        ),
                      ),
                      const SizedBox(height: 54.5),
                      const ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 342),
                        child: DashedDivider(),
                      ),
                      const SizedBox(height: 51.5),
                      SvgPicture.asset(
                        AppAssets.chartIllustration,
                        width: 90,
                        height: 90,
                      ),
                      const SizedBox(height: 16),
                      const ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 223),
                        child: _HeroTitle(),
                      ),
                      SizedBox(height: buttonSpacing),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('get-started-button'),
                          onPressed: () => _handleGetStarted(context),
                          child: const Text('Get Started'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          key: const Key('import-existing-profile-button'),
                          onPressed: () => showImportExistingProfileSheet(
                            context,
                            onImported: () => context.go(AppRoutes.home),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.surfaceMuted,
                            foregroundColor: AppColors.textSecondary,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: AppTextStyles.secondaryButton,
                          ),
                          child: Text.rich(
                            TextSpan(
                              style: AppTextStyles.secondaryButton,
                              children: const [
                                TextSpan(
                                  text: 'Have an existing profile? ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Import',
                                  style: TextStyle(color: AppColors.brandGreen),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'All-in-one\nSubscription\n'),
          TextSpan(
            text: 'Tracker',
            style: AppTextStyles.heroTitle.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      style: AppTextStyles.heroTitle,
    );
  }
}
