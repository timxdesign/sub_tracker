import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: PhoneViewport(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              IconButton(
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(height: 20),
              Text('Terms & Condition', style: AppTextStyles.sheetTitle),
              const SizedBox(height: 16),
              const _TermsSection(
                title: 'Offline usage',
                body:
                    'Subscription Tracker stores your profile, settings, and subscriptions locally on your device. No internet connection is required for the core product flows.',
              ),
              const _TermsSection(
                title: 'Your data',
                body:
                    'You are responsible for keeping local backups of your device data. Exported backups stay on your device unless you explicitly move them elsewhere.',
              ),
              const _TermsSection(
                title: 'Delete profile',
                body:
                    'Deleting your profile removes the local profile and subscription data tied to it from this device. This action cannot be undone unless you first export a backup.',
              ),
              const _TermsSection(
                title: 'Migration',
                body:
                    'Import and migration flows are designed for local device transfer only. No cloud restore or remote account service is used by this build.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
