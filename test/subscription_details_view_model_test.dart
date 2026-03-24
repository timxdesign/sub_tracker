import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/save_subscription.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/subscription_details_view_model.dart';

void main() {
  test(
    'renew updates the subscription billing date and reloads details',
    () async {
      final repository = _FakeSubscriptionsRepository(
        Subscription(
          id: 'netflix',
          name: 'Netflix Premium',
          category: SubscriptionCategory.apps,
          price: 8000,
          currencyCode: 'NGN',
          billingCycle: SubscriptionBillingCycle.monthly,
          nextBillingDate: DateTime(2026, 3, 24),
          createdAt: DateTime(2026, 2, 24),
          startDate: DateTime(2026, 2, 24),
          serviceProvider: 'Netflix',
          website: 'www.netflix.com',
        ),
      );
      final viewModel = SubscriptionDetailsViewModel(
        getSubscription: GetSubscriptionUseCase(repository),
        saveSubscription: SaveSubscriptionUseCase(repository),
      );

      await viewModel.load('netflix');
      expect(viewModel.subscription, isNotNull);
      expect(viewModel.subscription!.nextBillingDate, DateTime(2026, 3, 24));

      await viewModel.renew();

      expect(viewModel.subscription, isNotNull);
      expect(viewModel.subscription!.nextBillingDate, DateTime(2026, 4, 24));
      expect(repository.savedSubscriptions.single.id, 'netflix');
    },
  );
}

class _FakeSubscriptionsRepository implements SubscriptionsRepository {
  _FakeSubscriptionsRepository(this._subscription);

  Subscription _subscription;
  final List<Subscription> savedSubscriptions = [];

  @override
  Future<List<Subscription>> getSubscriptions() async => [_subscription];

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    return _subscription.id == id ? _subscription : null;
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    _subscription = subscription;
    savedSubscriptions.add(subscription);
  }
}
