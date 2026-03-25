import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sub_tracker/app/app.dart';
import 'package:sub_tracker/app/di/providers.dart';
import 'package:sub_tracker/core/database/app_database.dart';
import 'package:sub_tracker/features/profile/domain/models/profile.dart';
import 'package:sub_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:sub_tracker/features/profile/domain/usecases/get_stored_profile.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/home_dashboard_view_model.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows get started flow after the splash screen', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    final dependencies = await buildAppDependencies(
      preferences: preferences,
      httpClient: MockClient((request) async => http.Response('', 200)),
      appDatabase: AppDatabase.inMemory(),
    );

    await tester.pumpWidget(SubTrackerApp(dependencies: dependencies));

    expect(find.byKey(const Key('start-screen-logo')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('get-started-button')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const Key('import-existing-profile-button')),
    );
    await tester.tap(
      find.byKey(const Key('import-existing-profile-button')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('import-existing-profile-sheet')),
      findsOneWidget,
    );

    dependencies.dispose();
  });

  test('home dashboard view model derives preview data', () async {
    final now = DateTime.now();
    final subscriptionsRepository = _FakeSubscriptionsRepository([
      Subscription(
        id: 'netflix',
        name: 'Netflix Premium',
        category: SubscriptionCategory.apps,
        price: 8000,
        currencyCode: 'NGN',
        billingCycle: SubscriptionBillingCycle.monthly,
        nextBillingDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 22)),
      ),
    ]);
    final viewModel = HomeDashboardViewModel(
      getStoredProfile: GetStoredProfileUseCase(
        _FakeProfileRepository(
          Profile(
            fullName: 'Timothy Doe',
            email: 'timothy@example.com',
            createdAt: now.subtract(const Duration(days: 4)),
          ),
        ),
      ),
      getSubscriptions: GetSubscriptionsUseCase(subscriptionsRepository),
    );

    await viewModel.load();

    expect(viewModel.firstName, 'Timothy');
    expect(viewModel.activeCount, 1);
    expect(viewModel.upcomingPreview.single.name, 'Netflix Premium');
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
  Future<Profile?> updateProfile({
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
