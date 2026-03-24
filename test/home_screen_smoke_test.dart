import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sub_tracker/app/router/route_names.dart';
import 'package:sub_tracker/app/theme/app_theme.dart';
import 'package:sub_tracker/features/profile/domain/models/profile.dart';
import 'package:sub_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:sub_tracker/features/profile/domain/usecases/get_stored_profile.dart';
import 'package:sub_tracker/features/subscriptions/domain/models/subscription.dart';
import 'package:sub_tracker/features/subscriptions/domain/repositories/subscriptions_repository.dart';
import 'package:sub_tracker/features/subscriptions/domain/usecases/get_subscriptions.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/home_dashboard_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/screens/subscriptions_screen.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/home_dashboard_view_model.dart';
import 'package:sub_tracker/features/subscriptions/presentation/viewmodels/subscriptions_view_model.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_feature_widgets.dart';
import 'package:sub_tracker/features/subscriptions/presentation/widgets/subscription_primary_navigation.dart';

void main() {
  testWidgets('home screen renders visible content', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 720);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    )..load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<HomeDashboardViewModel>.value(
          value: viewModel,
          child: const HomeDashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hi, Timothy', skipOffstage: false), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('subscription-shell-add-button'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );

    final addButtonRect = tester.getRect(
      find.byKey(
        const ValueKey<String>('subscription-shell-add-button'),
        skipOffstage: false,
      ),
    );
    final greetingRect = tester.getRect(
      find.text('Hi, Timothy', skipOffstage: false),
    );
    expect(greetingRect.top, lessThan(140));
    expect(addButtonRect.top, greaterThan(560));
  });

  testWidgets(
    'home category preview opens subscriptions list with matching category selected',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 720);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
        Subscription(
          id: 'chatgpt',
          name: 'ChatGPT Plus',
          category: SubscriptionCategory.tools,
          price: 20000,
          currencyCode: 'NGN',
          billingCycle: SubscriptionBillingCycle.monthly,
          nextBillingDate: now.add(const Duration(days: 10)),
          createdAt: now.subtract(const Duration(days: 40)),
        ),
      ]);

      final profileRepository = _FakeProfileRepository(
        Profile(
          fullName: 'Timothy Doe',
          email: 'timothy@example.com',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      );

      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) {
              return ChangeNotifierProvider(
                create: (_) => HomeDashboardViewModel(
                  getStoredProfile: GetStoredProfileUseCase(profileRepository),
                  getSubscriptions: GetSubscriptionsUseCase(
                    subscriptionsRepository,
                  ),
                )..load(),
                child: const HomeDashboardScreen(),
              );
            },
          ),
          GoRoute(
            path: '/subscriptions/:category',
            builder: (context, state) {
              final category = SubscriptionCategory.tryParseSlug(
                state.pathParameters['category'] ?? '',
              );
              return ChangeNotifierProvider(
                create: (_) =>
                    SubscriptionsViewModel(
                      getSubscriptions: GetSubscriptionsUseCase(
                        subscriptionsRepository,
                      ),
                    )..load(
                      displayMode: SubscriptionDisplayMode.list,
                      selectedCategory: category,
                      resetSelectedCategory: category == null,
                    ),
                child: const SubscriptionsScreen(),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(
        find.byKey(const ValueKey('home-category-preview-apps')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SubscriptionsScreen), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SubscriptionFilterChip &&
              widget.label == 'Apps' &&
              widget.isSelected,
        ),
        findsOneWidget,
      );
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/subscriptions/apps',
      );
    },
  );

  testWidgets(
    'primary dock switches branches like tabs and preserves subscriptions state',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 720);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
        Subscription(
          id: 'chatgpt',
          name: 'ChatGPT Plus',
          category: SubscriptionCategory.tools,
          price: 20000,
          currencyCode: 'NGN',
          billingCycle: SubscriptionBillingCycle.monthly,
          nextBillingDate: now.add(const Duration(days: 10)),
          createdAt: now.subtract(const Duration(days: 40)),
        ),
      ]);

      final profileRepository = _FakeProfileRepository(
        Profile(
          fullName: 'Timothy Doe',
          email: 'timothy@example.com',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      );

      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return SubscriptionPrimaryNavigationScope(
                navigationShell: navigationShell,
                child: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.home,
                    builder: (context, state) {
                      return ChangeNotifierProvider(
                        create: (_) => HomeDashboardViewModel(
                          getStoredProfile: GetStoredProfileUseCase(
                            profileRepository,
                          ),
                          getSubscriptions: GetSubscriptionsUseCase(
                            subscriptionsRepository,
                          ),
                        )..load(),
                        child: const HomeDashboardScreen(),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.subscriptions,
                    builder: (context, state) {
                      final displayMode =
                          state.uri.queryParameters['view'] == 'list'
                          ? SubscriptionDisplayMode.list
                          : SubscriptionDisplayMode.grid;
                      return ChangeNotifierProvider(
                        create: (_) =>
                            SubscriptionsViewModel(
                              getSubscriptions: GetSubscriptionsUseCase(
                                subscriptionsRepository,
                              ),
                            )..load(
                              displayMode: displayMode,
                              resetSelectedCategory: true,
                            ),
                        child: const SubscriptionsScreen(),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':category',
                        builder: (context, state) {
                          final category = SubscriptionCategory.tryParseSlug(
                            state.pathParameters['category'] ?? '',
                          );
                          return ChangeNotifierProvider(
                            create: (_) =>
                                SubscriptionsViewModel(
                                  getSubscriptions: GetSubscriptionsUseCase(
                                    subscriptionsRepository,
                                  ),
                                )..load(
                                  displayMode: SubscriptionDisplayMode.list,
                                  selectedCategory: category,
                                  resetSelectedCategory: category == null,
                                ),
                            child: const SubscriptionsScreen(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.insights,
                    builder: (context, state) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.settings,
                    builder: (context, state) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(
        find.byKey(const ValueKey('home-category-preview-apps')),
      );
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/subscriptions/apps',
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SubscriptionFilterChip &&
              widget.label == 'Apps' &&
              widget.isSelected,
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('subscription-shell-nav-home')),
      );
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.toString(), '/home');
      expect(find.text('Hi, Timothy', skipOffstage: false), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('subscription-shell-nav-subscriptions')),
      );
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/subscriptions/apps',
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SubscriptionFilterChip &&
              widget.label == 'Apps' &&
              widget.isSelected,
        ),
        findsOneWidget,
      );
    },
  );
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
