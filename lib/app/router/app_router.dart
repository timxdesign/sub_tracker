import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/onboarding/presentation/screens/get_started_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/viewmodels/get_started_view_model.dart';
import '../../features/onboarding/presentation/viewmodels/splash_view_model.dart';
import '../../features/profile/presentation/screens/create_profile_screen.dart';
import '../../features/profile/presentation/viewmodels/create_profile_view_model.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscriptions/domain/models/subscription.dart';
import '../../features/subscriptions/presentation/screens/home_dashboard_screen.dart';
import '../../features/subscriptions/presentation/screens/sub_insight_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_details_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_form_screen.dart';
import '../../features/subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../features/subscriptions/presentation/screens/upcoming_payments_screen.dart';
import '../../features/subscriptions/presentation/viewmodels/home_dashboard_view_model.dart';
import '../../features/subscriptions/presentation/viewmodels/subscription_details_view_model.dart';
import '../../features/subscriptions/presentation/viewmodels/subscription_form_view_model.dart';
import '../../features/subscriptions/presentation/viewmodels/subscriptions_view_model.dart';
import '../../features/subscriptions/presentation/viewmodels/upcoming_payments_view_model.dart';
import '../di/providers.dart';
import 'route_names.dart';

GoRouter createAppRouter(AppDependencies dependencies) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => SplashViewModel(
              getOnboardingStatus: dependencies.getOnboardingStatus,
              getStoredProfile: dependencies.getStoredProfile,
            ),
            child: const SplashScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRouteNames.welcome,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => GetStartedViewModel(
              completeOnboarding: dependencies.completeOnboarding,
            ),
            child: const GetStartedScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createProfile,
        name: AppRouteNames.createProfile,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => CreateProfileViewModel(
              createProfile: dependencies.createProfile,
              syncPendingProfile: dependencies.syncPendingProfile,
            ),
            child: const CreateProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRouteNames.home,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => HomeDashboardViewModel(
              getStoredProfile: dependencies.getStoredProfile,
              getSubscriptions: dependencies.getSubscriptions,
            )..load(),
            child: const HomeDashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/subscriptions/details/:id',
        name: AppRouteNames.subscriptionDetails,
        builder: (context, state) {
          final subscriptionId = state.pathParameters['id']!;
          return ChangeNotifierProvider(
            create: (_) => SubscriptionDetailsViewModel(
              getSubscription: dependencies.getSubscription,
            )..load(subscriptionId),
            child: const SubscriptionDetailsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        name: AppRouteNames.subscriptions,
        builder: (context, state) {
          final displayMode = state.uri.queryParameters['view'] == 'list'
              ? SubscriptionDisplayMode.list
              : SubscriptionDisplayMode.grid;
          return ChangeNotifierProvider(
            create: (_) => SubscriptionsViewModel(
              getSubscriptions: dependencies.getSubscriptions,
            )..load(
                displayMode: displayMode,
                resetSelectedCategory: true,
              ),
            child: const SubscriptionsScreen(),
          );
        },
      ),
      GoRoute(
        path: '/subscriptions/:category',
        name: AppRouteNames.categorySubscriptions,
        builder: (context, state) {
          final category = SubscriptionCategory.tryParseSlug(
            state.pathParameters['category'] ?? '',
          );
          return ChangeNotifierProvider(
            create: (_) => SubscriptionsViewModel(
              getSubscriptions: dependencies.getSubscriptions,
            )..load(
                displayMode: SubscriptionDisplayMode.list,
                selectedCategory: category,
                resetSelectedCategory: category == null,
              ),
            child: const SubscriptionsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.insights,
        name: AppRouteNames.insights,
        builder: (context, state) => const SubInsightScreen(),
      ),
      GoRoute(
        path: AppRoutes.upcoming,
        name: AppRouteNames.upcoming,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => UpcomingPaymentsViewModel(
              getUpcomingPayments: dependencies.getUpcomingPayments,
            )..load(),
            child: const UpcomingPaymentsScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newSubscription,
        name: AppRouteNames.newSubscription,
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => SubscriptionFormViewModel(
              saveSubscription: dependencies.saveSubscription,
            ),
            child: const SubscriptionFormScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
