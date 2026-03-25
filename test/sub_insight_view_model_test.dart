import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/sub_insight_view_model.dart';

void main() {
  test('sub insight view model derives monthly insight metrics', () async {
    final now = DateTime(2026, 3, 24);
    final viewModel = SubInsightViewModel(
      getSubscriptions: GetSubscriptionsUseCase(
        _FakeSubscriptionsRepository([
          Subscription(
            id: 'apps-a',
            name: 'Netflix Premium',
            category: SubscriptionCategory.apps,
            price: 5000,
            currencyCode: 'NGN',
            billingCycle: SubscriptionBillingCycle.monthly,
            nextBillingDate: DateTime(2026, 3, 10),
            createdAt: DateTime(2026, 3, 2),
          ),
          Subscription(
            id: 'apps-b',
            name: 'Spotify Family',
            category: SubscriptionCategory.apps,
            price: 7000,
            currencyCode: 'NGN',
            billingCycle: SubscriptionBillingCycle.monthly,
            nextBillingDate: DateTime(2026, 3, 22),
            createdAt: DateTime(2026, 2, 10),
          ),
          Subscription(
            id: 'vehicle-a',
            name: 'Vehicle Tracking',
            category: SubscriptionCategory.vehicle,
            price: 8000,
            currencyCode: 'NGN',
            billingCycle: SubscriptionBillingCycle.monthly,
            nextBillingDate: DateTime(2026, 3, 1),
            createdAt: DateTime(2026, 3, 5),
          ),
          Subscription(
            id: 'other-a',
            name: 'Legacy Service',
            category: SubscriptionCategory.others,
            price: 15000,
            currencyCode: 'NGN',
            billingCycle: SubscriptionBillingCycle.monthly,
            nextBillingDate: DateTime(2026, 2, 15),
            createdAt: DateTime(2026, 1, 20),
          ),
        ]),
      ),
      now: () => now,
    );

    await viewModel.load();

    expect(viewModel.selectedMonthLabel, 'March');
    expect(viewModel.totalSubscriptions, 4);
    expect(viewModel.spendForSelectedMonth, 20000);
    expect(viewModel.spendChangeFromPreviousMonth, 5000);
    expect(viewModel.newSubscriptionsCount, 2);
    expect(viewModel.cancelledSubscriptionsCount, 3);
    expect(viewModel.topCategory?.category, SubscriptionCategory.apps);

    final appsSummary = viewModel.categorySummaries.firstWhere(
      (summary) => summary.category == SubscriptionCategory.apps,
    );
    final vehicleSummary = viewModel.categorySummaries.firstWhere(
      (summary) => summary.category == SubscriptionCategory.vehicle,
    );

    expect(appsSummary.count, 2);
    expect(vehicleSummary.count, 1);
  });
}

class _FakeSubscriptionsRepository implements SubscriptionsRepository {
  const _FakeSubscriptionsRepository(this.items);

  final List<Subscription> items;

  @override
  Future<List<Subscription>> getSubscriptions() async => items;

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {}
}
