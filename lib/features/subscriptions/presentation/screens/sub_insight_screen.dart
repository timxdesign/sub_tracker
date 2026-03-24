import 'dart:math' as math;

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
import '../viewmodels/sub_insight_view_model.dart';
import '../widgets/subscription_feature_widgets.dart';
import '../widgets/subscription_primary_navigation.dart';

class SubInsightScreen extends StatelessWidget {
  const SubInsightScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final didCreate = await context.push<bool>(AppRoutes.newSubscription);
    if (didCreate == true && context.mounted) {
      await context.read<SubInsightViewModel>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubInsightViewModel>(
      builder: (context, viewModel, _) {
        final primaryNavigation = SubscriptionPrimaryNavigationScope.of(
          context,
        );
        return SubscriptionShellScaffold(
          destination: SubscriptionPrimaryDestination.insights,
          onHomeTap: () => primaryNavigation.goHome(),
          onSubscriptionsTap: () => primaryNavigation.goSubscriptions(),
          onInsightsTap: () => primaryNavigation.goInsights(),
          onSettingsTap: () => primaryNavigation.goSettings(),
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

  Widget _buildBody(BuildContext context, SubInsightViewModel viewModel) {
    final currencyCode =
        context.watch<AppPreferencesController?>()?.currencyCode ?? 'NGN';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Sub Insight', style: AppTextStyles.sheetTitle),
            ),
            IgnorePointer(
              ignoring: !viewModel.hasSubscriptions,
              child: Opacity(
                opacity: viewModel.hasSubscriptions ? 1 : 0,
                child: _MonthPill(label: viewModel.selectedMonthLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (viewModel.isLoading && !viewModel.hasSubscriptions)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                viewModel.errorMessage!,
                style: AppTextStyles.bodyMuted,
              ),
            ),
          if (!viewModel.hasSubscriptions)
            const SizedBox(
              height: 560,
              child: Center(child: _InsightEmptyState()),
            )
          else ...[
            _SpentSummaryCard(viewModel: viewModel, currencyCode: currencyCode),
            const SizedBox(height: 12),
            _InsightChartCard(viewModel: viewModel),
            const SizedBox(height: 12),
            _CategoryBreakdownCard(viewModel: viewModel),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InsightMetricCard(
                    value:
                        '+${formatTwoDigits(viewModel.newSubscriptionsCount)}',
                    label: 'New Sub',
                    accentColor: const Color(0xFF54D62C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightMetricCard(
                    value: formatTwoDigits(
                      viewModel.cancelledSubscriptionsCount,
                    ),
                    label: 'Cancelled sub',
                    accentColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMuted.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpentSummaryCard extends StatelessWidget {
  const _SpentSummaryCard({
    required this.viewModel,
    required this.currencyCode,
  });

  final SubInsightViewModel viewModel;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final delta = viewModel.spendChangeFromPreviousMonth;
    final deltaLabel = _formatSignedDelta(delta, currencyCode);

    return SizedBox(
      height: 99,
      child: SurfaceCard(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                deltaLabel,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: delta > 0
                      ? AppColors.error
                      : delta < 0
                      ? AppColors.brandGreen
                      : AppColors.textSecondary,
                  height: 26 / 16,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(
                      currencyCode,
                      viewModel.spendForSelectedMonth,
                    ),
                    style: AppTextStyles.screenTitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                      children: [
                        const TextSpan(text: 'Spent '),
                        TextSpan(
                          text: viewModel.selectedMonthLabel,
                          style: const TextStyle(color: AppColors.brandGreen),
                        ),
                      ],
                    ),
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

class _InsightChartCard extends StatelessWidget {
  const _InsightChartCard({required this.viewModel});

  final SubInsightViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final topCategory = viewModel.topCategory;
    final segments = _donutOrder
        .map((category) {
          final summary = viewModel.categorySummaries.firstWhere(
            (item) => item.category == category,
          );
          return summary.count > 0
              ? _DonutSegment(
                  value: summary.count.toDouble(),
                  color: _insightColorForCategory(category),
                )
              : null;
        })
        .whereType<_DonutSegment>()
        .toList(growable: false);

    return SizedBox(
      height: 265,
      child: SurfaceCard(
        radius: 16,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: SizedBox.square(
                dimension: 224,
                child: CustomPaint(
                  painter: _InsightDonutPainter(segments: segments),
                ),
              ),
            ),
            if (topCategory != null)
              Positioned(
                left: 42,
                top: 34,
                child: _TopCategoryBadge(summary: topCategory),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total sub',
                    style: AppTextStyles.smallLabel.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.totalSubscriptions.toString(),
                    style: AppTextStyles.screenTitle.copyWith(
                      fontSize: 28,
                      height: 1.2,
                      letterSpacing: -0.28,
                    ),
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

class _TopCategoryBadge extends StatelessWidget {
  const _TopCategoryBadge({required this.summary});

  final InsightCategorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4F6F8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _insightCategoryLabel(summary.category),
            style: AppTextStyles.bodyMuted.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            summary.count.toString(),
            style: AppTextStyles.smallLabel.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.viewModel});

  final SubInsightViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final summaries = viewModel.categorySummaries;
    final leftColumn = summaries.take(4).toList(growable: false);
    final rightColumn = summaries.skip(4).toList(growable: false);

    return SizedBox(
      height: 168,
      child: SurfaceCard(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _CategoryBreakdownColumn(summaries: leftColumn)),
            const SizedBox(width: 27),
            Expanded(child: _CategoryBreakdownColumn(summaries: rightColumn)),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownColumn extends StatelessWidget {
  const _CategoryBreakdownColumn({required this.summaries});

  final List<InsightCategorySummary> summaries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: summaries
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final summary = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == summaries.length - 1 ? 0 : 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SubscriptionCategoryIcon(
                          category: summary.category,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _insightCategoryLabel(summary.category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    summary.count.toString(),
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                      letterSpacing: -0.14,
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _InsightMetricCard extends StatelessWidget {
  const _InsightMetricCard({
    required this.value,
    required this.label,
    required this.accentColor,
  });

  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 99,
      child: SurfaceCard(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.screenTitle.copyWith(color: accentColor),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightEmptyState extends StatelessWidget {
  const _InsightEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.folderIllustration,
          width: 64.875,
          height: 64.875,
        ),
        const SizedBox(height: 16),
        Text(
          'No subscription',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InsightDonutPainter extends CustomPainter {
  _InsightDonutPainter({required this.segments});

  final List<_DonutSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 34.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.value,
    );

    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1F4F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (total <= 0) {
      return;
    }

    var startAngle = -math.pi / 2;
    final gapAngle = segments.length > 1 ? 0.12 : 0.0;

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * (math.pi * 2);
      final adjustedSweep = math.max(0.02, sweepAngle - gapAngle);
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle + (gapAngle / 2),
        adjustedSweep,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _InsightDonutPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) {
      return true;
    }

    for (var index = 0; index < segments.length; index++) {
      final current = segments[index];
      final previous = oldDelegate.segments[index];
      if (current.value != previous.value || current.color != previous.color) {
        return true;
      }
    }

    return false;
  }
}

class _DonutSegment {
  const _DonutSegment({required this.value, required this.color});

  final double value;
  final Color color;
}

const _donutOrder = <SubscriptionCategory>[
  SubscriptionCategory.dataPlan,
  SubscriptionCategory.apps,
  SubscriptionCategory.tools,
  SubscriptionCategory.identity,
  SubscriptionCategory.vehicle,
  SubscriptionCategory.insurance,
  SubscriptionCategory.other,
  SubscriptionCategory.health,
];

Color _insightColorForCategory(SubscriptionCategory category) {
  switch (category) {
    case SubscriptionCategory.dataPlan:
      return const Color(0xFF2D8CF0);
    case SubscriptionCategory.apps:
      return const Color(0xFFFFC21A);
    case SubscriptionCategory.tools:
      return Colors.black;
    case SubscriptionCategory.health:
      return const Color(0xFF54D62C);
    case SubscriptionCategory.vehicle:
      return const Color(0xFFFF5147);
    case SubscriptionCategory.insurance:
      return const Color(0xFF3D66F6);
    case SubscriptionCategory.identity:
      return const Color(0xFF8F2EFF);
    case SubscriptionCategory.other:
      return const Color(0xFF6B7B8E);
  }
}

String _insightCategoryLabel(SubscriptionCategory category) {
  if (category == SubscriptionCategory.other) {
    return 'Others';
  }
  return category.label;
}

String _formatSignedDelta(double value, String currencyCode) {
  final rounded = value.roundToDouble();
  if (rounded == 0) {
    return '0';
  }

  final formatted = formatCurrency(
    currencyCode,
    rounded.abs(),
  ).replaceFirst(RegExp(r'^[^\d]+'), '');
  return '${rounded.isNegative ? '-' : '+'}$formatted';
}
