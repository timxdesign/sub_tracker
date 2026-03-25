import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_screen.dart';
import '../../../../core/widgets/phone_viewport.dart';
import '../../domain/models/subscription.dart';

enum SubscriptionPrimaryDestination { home, subscriptions, insights, settings }

class SubscriptionShellScaffold extends StatelessWidget {
  const SubscriptionShellScaffold({
    super.key,
    required this.child,
    required this.destination,
    required this.onHomeTap,
    required this.onSubscriptionsTap,
    required this.onInsightsTap,
    required this.onSettingsTap,
    required this.onAddTap,
  });

  final Widget child;
  final SubscriptionPrimaryDestination destination;
  final VoidCallback onHomeTap;
  final VoidCallback onSubscriptionsTap;
  final VoidCallback onInsightsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pageHorizontalPadding;
    final bottomPadding = context.responsiveSpacing.navigationBottom;
    return AppScreen(
      backgroundColor: AppColors.background,
      child: PhoneViewport(
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                minimum: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.primaryNavigationMaxWidth,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 208,
                          height: 64,
                          child: _BottomDock(
                            destination: destination,
                            onHomeTap: onHomeTap,
                            onSubscriptionsTap: onSubscriptionsTap,
                            onInsightsTap: onInsightsTap,
                            onSettingsTap: onSettingsTap,
                          ),
                        ),
                        const Spacer(),
                        _AddSubscriptionButton(onTap: onAddTap),
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
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandGreen,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.brandGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class SubscriptionCategoryIcon extends StatelessWidget {
  const SubscriptionCategoryIcon({
    super.key,
    required this.category,
    this.size = 18,
  });

  final SubscriptionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetPathForCategory(category);
    if (assetPath != null) {
      return SvgPicture.asset(assetPath, width: size, height: size);
    }

    return Icon(
      _fallbackIconForCategory(category),
      size: size,
      color: _accentColorForCategory(category),
    );
  }
}

class SubscriptionFilterChip extends StatelessWidget {
  const SubscriptionFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: isSelected
                  ? AppTextStyles.tabLabelActive
                  : AppTextStyles.tabLabel,
            ),
            const SizedBox(width: 8),
            Text(
              formatTwoDigits(count),
              style:
                  (isSelected
                          ? AppTextStyles.smallLabel.copyWith(
                              color: Colors.white70,
                            )
                          : AppTextStyles.smallLabel)
                      .copyWith(
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionSearchField extends StatelessWidget {
  const SubscriptionSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.inputValue,
              decoration: const InputDecoration(
                hintText: 'Search subscription',
                hintStyle: AppTextStyles.inputPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPaymentTile extends StatelessWidget {
  const SubscriptionPaymentTile({
    super.key,
    required this.subscription,
    this.onTap,
  });

  final Subscription subscription;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = AppTextStyles.bodyMuted.copyWith(
      color: subscription.expiresToday || subscription.isExpired
          ? AppColors.error
          : AppColors.textSecondary,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SubscriptionAvatar(subscription: subscription),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_statusLabel(subscription), style: subtitleStyle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatCurrency(subscription.currencyCode, subscription.price),
              style: AppTextStyles.subscriptionAmount.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionAvatar extends StatelessWidget {
  const SubscriptionAvatar({super.key, required this.subscription});

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    final logoAsset = subscriptionLogoAssetForName(subscription.name);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: logoAsset == null
          ? Text(
              _avatarText(subscription.name),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: _accentColorForCategory(subscription.category),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: Image.asset(
                  logoAsset,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}

class SubscriptionBrandAvatar extends StatelessWidget {
  const SubscriptionBrandAvatar({
    super.key,
    required this.subscriptionName,
    this.size = 64,
  });

  final String subscriptionName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoAsset = subscriptionLogoAssetForName(subscriptionName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size / 12),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: logoAsset == null
            ? Text(
                _avatarText(subscriptionName),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGreen,
                ),
              )
            : Padding(
                padding: EdgeInsets.all(size / 6),
                child: ClipOval(
                  child: Image.asset(
                    logoAsset,
                    width: size / 2.4,
                    height: size / 2.4,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.assetPath,
    required this.label,
  });

  final String assetPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      child: Column(
        children: [
          SvgPicture.asset(assetPath, width: 28, height: 28),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  const _BottomDock({
    required this.destination,
    required this.onHomeTap,
    required this.onSubscriptionsTap,
    required this.onInsightsTap,
    required this.onSettingsTap,
  });

  final SubscriptionPrimaryDestination destination;
  final VoidCallback onHomeTap;
  final VoidCallback onSubscriptionsTap;
  final VoidCallback onInsightsTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF4F6F8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DockIcon(
              key: const ValueKey('subscription-shell-nav-home'),
              assetPath: AppAssets.homeNavIcon,
              isSelected: destination == SubscriptionPrimaryDestination.home,
              assetColor: destination == SubscriptionPrimaryDestination.home
                  ? null
                  : AppColors.navInactive,
              onTap: onHomeTap,
            ),
            _DockIcon(
              key: const ValueKey('subscription-shell-nav-subscriptions'),
              assetPath:
                  destination == SubscriptionPrimaryDestination.subscriptions
                  ? AppAssets.subscriptionsNavActive
                  : AppAssets.subscriptionsNavInactive,
              isSelected:
                  destination == SubscriptionPrimaryDestination.subscriptions,
              onTap: onSubscriptionsTap,
            ),
            _DockIcon(
              key: const ValueKey('subscription-shell-nav-insights'),
              assetPath: destination == SubscriptionPrimaryDestination.insights
                  ? AppAssets.insightsNavActive
                  : AppAssets.insightsNavInactive,
              isSelected:
                  destination == SubscriptionPrimaryDestination.insights,
              onTap: onInsightsTap,
            ),
            _DockIcon(
              key: const ValueKey('subscription-shell-nav-settings'),
              assetPath: destination == SubscriptionPrimaryDestination.settings
                  ? AppAssets.settingsNavActive
                  : AppAssets.settingsNavInactive,
              isSelected:
                  destination == SubscriptionPrimaryDestination.settings,
              onTap: onSettingsTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.assetPath,
    this.assetColor,
  });

  final String? assetPath;
  final Color? assetColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: assetPath != null
            ? SvgPicture.asset(
                assetPath!,
                width: 20,
                height: 20,
                colorFilter: assetColor == null
                    ? null
                    : ColorFilter.mode(assetColor!, BlendMode.srcIn),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _AddSubscriptionButton extends StatelessWidget {
  const _AddSubscriptionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      key: const ValueKey('subscription-shell-add-button'),
      onTap: onTap,
      radius: 36,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.brandGreen,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(AppAssets.addIcon, width: 24, height: 24),
      ),
    );
  }
}

String _statusLabel(Subscription subscription) {
  if (subscription.expiresToday) {
    return 'Expires Today';
  }
  if (subscription.isExpired) {
    return 'Expired ${formatPaymentDate(subscription.nextBillingDate)}';
  }
  return 'Expires ${formatPaymentDate(subscription.nextBillingDate)}';
}

String _avatarText(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }

  final words = trimmed.split(RegExp(r'\s+'));
  if (words.length == 1) {
    return words.first.substring(0, 1).toUpperCase();
  }

  return '${words.first[0]}${words.last[0]}'.toUpperCase();
}

String? _assetPathForCategory(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.dataPlan:
      return AppAssets.dataPlanIcon;
    case SubscriptionCategory.apps:
      return AppAssets.appsIcon;
    case SubscriptionCategory.tools:
      return AppAssets.toolsIcon;
    case SubscriptionCategory.health:
      return AppAssets.healthIcon;
    case SubscriptionCategory.insurance:
      return AppAssets.insuranceIcon;
    case SubscriptionCategory.identity:
      return AppAssets.identityIcon;
    case SubscriptionCategory.others:
      return AppAssets.otherIcon;
    case SubscriptionCategory.vehicle:
      return null;
  }
}

Color _accentColorForCategory(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.dataPlan:
      return AppColors.info;
    case SubscriptionCategory.apps:
      return AppColors.warning;
    case SubscriptionCategory.tools:
      return Colors.black;
    case SubscriptionCategory.health:
      return const Color(0xFF69D54F);
    case SubscriptionCategory.vehicle:
      return AppColors.error;
    case SubscriptionCategory.insurance:
      return const Color(0xFF466AF6);
    case SubscriptionCategory.identity:
      return const Color(0xFF8F2EFF);
    case SubscriptionCategory.others:
      return const Color(0xFF677788);
  }
}

IconData _fallbackIconForCategory(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.vehicle:
      return Icons.directions_car_filled_rounded;
    default:
      return Icons.blur_on_rounded;
  }
}

String? subscriptionLogoAssetForName(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('airtel')) {
    return AppAssets.airtelLogo;
  }
  if (normalized.contains('netflix')) {
    return AppAssets.netflixLogo;
  }
  if (normalized.contains('chatgpt') || normalized.contains('openai')) {
    return AppAssets.openAiLogo;
  }
  if (normalized.contains('license') || normalized.contains('identity')) {
    return AppAssets.idLogo;
  }
  if (normalized.contains('prime')) {
    return AppAssets.primeVideoLogo;
  }
  if (normalized.contains('mtn')) {
    return AppAssets.mtnLogo;
  }
  return null;
}
