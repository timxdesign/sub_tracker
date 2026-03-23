import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sub_tracker/features/profile/domain/models/profile.dart';
import 'package:sub_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:sub_tracker/features/profile/domain/usecases/get_stored_profile.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_dashboard_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/home_dashboard_view_model.dart';

void main() {
  testWidgets('home screen renders visible content', (tester) async {
    final subscriptionsRepository = _FakeSubscriptionsRepository([
      Subscription(
        id: 'netflix',
        name: 'Netflix Premium',
        category: SubscriptionCategory.apps,
        price: 8000,
        currencyCode: 'NGN',
        billingCycle: SubscriptionBillingCycle.monthly,
        nextBillingDate: DateTime(2026, 3, 23),
        createdAt: DateTime(2026, 3, 1),
      ),
    ]);

    final viewModel = HomeDashboardViewModel(
      getStoredProfile: GetStoredProfileUseCase(
        _FakeProfileRepository(
          Profile(
            fullName: 'Timothy Doe',
            email: 'timothy@example.com',
            createdAt: DateTime(2026, 3, 20),
          ),
        ),
      ),
      getSubscriptions: GetSubscriptionsUseCase(subscriptionsRepository),
    )..load();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomeDashboardViewModel>.value(
          value: viewModel,
          child: const HomeDashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Hi, Timothy', skipOffstage: false), findsOneWidget);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  const _FakeProfileRepository(this.profile);

  final Profile? profile;

  @override
  Future<Profile?> getStoredProfile() async => profile;

  @override
  Future<Profile?> getPendingProfile() async => null;

  @override
  Future<Profile> createProfile({
    required String fullName,
    required String email,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> syncPendingProfile() async {}

  @override
  void startSyncLoop() {}

  @override
  void dispose() {}
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
