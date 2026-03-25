import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/save_subscription.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/subscription_details_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/subscription_details_view_model.dart';

void main() {
  testWidgets(
    'renders the details view as an overlay with a single footer action bar',
    (tester) async {
      final repository = _FakeDetailsRepository(
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
          website: 'netflix.com',
        ),
      );
      final viewModel = SubscriptionDetailsViewModel(
        getSubscription: GetSubscriptionUseCase(repository),
        saveSubscription: SaveSubscriptionUseCase(repository),
      );
      await viewModel.load('netflix');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: viewModel,
            child: const SubscriptionDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('subscription-details-overlay')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('subscription-details-close-button')),
        findsOneWidget,
      );
      expect(find.text('Details'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Edit'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    },
  );
}

class _FakeDetailsRepository implements SubscriptionsRepository {
  _FakeDetailsRepository(this.subscription);

  Subscription subscription;

  @override
  Future<List<Subscription>> getSubscriptions() async => [subscription];

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    return subscription.id == id ? subscription : null;
  }

  @override
  Future<void> saveSubscription(Subscription updatedSubscription) async {
    subscription = updatedSubscription;
  }
}
