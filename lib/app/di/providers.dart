import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/network/app_endpoints.dart';
import '../../core/storage/app_backup_file_store.dart';
import '../../core/storage/json_preferences_store.dart';
import '../../core/storage/legacy_preferences_migrator.dart';
import '../../features/onboarding/data/datasources/onboarding_local_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_status.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_profile.dart';
import '../../features/profile/domain/usecases/get_stored_profile.dart';
import '../../features/profile/domain/usecases/sync_pending_profile.dart';
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/viewmodels/app_preferences_controller.dart';
import '../../features/subscriptions/data/datasources/subscriptions_local_data_source.dart';
import '../../features/subscriptions/data/datasources/subscriptions_remote_data_source.dart';
import '../../features/subscriptions/data/repositories/subscriptions_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscriptions_repository.dart';
import '../../features/subscriptions/domain/usecases/get_subscription.dart';
import '../../features/subscriptions/domain/usecases/get_subscriptions.dart';
import '../../features/subscriptions/domain/usecases/get_upcoming_payments.dart';
import '../../features/subscriptions/domain/usecases/save_subscription.dart';

class AppDependencies {
  AppDependencies({
    required this.appDatabase,
    required this.httpClient,
    required this.onboardingRepository,
    required this.profileRepository,
    required this.subscriptionsRepository,
    required this.getOnboardingStatus,
    required this.completeOnboarding,
    required this.getStoredProfile,
    required this.createProfile,
    required this.syncPendingProfile,
    required this.settingsRepository,
    required this.getSubscriptions,
    required this.getSubscription,
    required this.getUpcomingPayments,
    required this.saveSubscription,
  });

  final AppDatabase appDatabase;
  final http.Client httpClient;
  final OnboardingRepository onboardingRepository;
  final ProfileRepository profileRepository;
  final SubscriptionsRepository subscriptionsRepository;
  final GetOnboardingStatusUseCase getOnboardingStatus;
  final CompleteOnboardingUseCase completeOnboarding;
  final GetStoredProfileUseCase getStoredProfile;
  final CreateProfileUseCase createProfile;
  final SyncPendingProfileUseCase syncPendingProfile;
  final SettingsRepository settingsRepository;
  final GetSubscriptionsUseCase getSubscriptions;
  final GetSubscriptionUseCase getSubscription;
  final GetUpcomingPaymentsUseCase getUpcomingPayments;
  final SaveSubscriptionUseCase saveSubscription;

  void startBackgroundWork() {
    profileRepository.startSyncLoop();
  }

  Future<void> flushPendingSyncs() async {
    await syncPendingProfile();
  }

  void dispose() {
    profileRepository.dispose();
    unawaited(appDatabase.close());
    httpClient.close();
  }
}

Future<AppDependencies> buildAppDependencies({
  required SharedPreferences preferences,
  required http.Client httpClient,
  AppDatabase? appDatabase,
  AppBackupFileStore? backupFileStore,
}) async {
  final store = JsonPreferencesStore(preferences);
  final database = appDatabase ?? AppDatabase();
  final profileLocalDataSource = ProfileLocalDataSource(database);
  final subscriptionsLocalDataSource = SubscriptionsLocalDataSource(database);

  await LegacyPreferencesMigrator(
    store: store,
    profileLocalDataSource: profileLocalDataSource,
    subscriptionsLocalDataSource: subscriptionsLocalDataSource,
  ).migrate();

  final onboardingRepository = OnboardingRepositoryImpl(
    localDataSource: OnboardingLocalDataSource(store),
  );

  final profileRepository = ProfileRepositoryImpl(
    localDataSource: profileLocalDataSource,
    remoteDataSource: ProfileRemoteDataSource(
      client: httpClient,
      endpoint: AppEndpoints.profileSync,
    ),
  );

  final subscriptionsRepository = SubscriptionsRepositoryImpl(
    localDataSource: subscriptionsLocalDataSource,
    remoteDataSource: SubscriptionsRemoteDataSource(
      client: httpClient,
      endpoint: AppEndpoints.subscriptionsSync,
    ),
  );

  final settingsRepository = SettingsRepositoryImpl(
    localDataSource: SettingsLocalDataSource(
      store: store,
      backupFileStore: backupFileStore ?? AppBackupFileStore(),
      profileLocalDataSource: profileLocalDataSource,
      subscriptionsLocalDataSource: subscriptionsLocalDataSource,
    ),
  );

  return AppDependencies(
    appDatabase: database,
    httpClient: httpClient,
    onboardingRepository: onboardingRepository,
    profileRepository: profileRepository,
    subscriptionsRepository: subscriptionsRepository,
    getOnboardingStatus: GetOnboardingStatusUseCase(onboardingRepository),
    completeOnboarding: CompleteOnboardingUseCase(onboardingRepository),
    getStoredProfile: GetStoredProfileUseCase(profileRepository),
    createProfile: CreateProfileUseCase(profileRepository),
    syncPendingProfile: SyncPendingProfileUseCase(profileRepository),
    settingsRepository: settingsRepository,
    getSubscriptions: GetSubscriptionsUseCase(subscriptionsRepository),
    getSubscription: GetSubscriptionUseCase(subscriptionsRepository),
    getUpcomingPayments: GetUpcomingPaymentsUseCase(subscriptionsRepository),
    saveSubscription: SaveSubscriptionUseCase(subscriptionsRepository),
  );
}

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.dependencies,
    required this.child,
  });

  final AppDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDependencies>.value(value: dependencies),
        Provider<OnboardingRepository>.value(
          value: dependencies.onboardingRepository,
        ),
        Provider<ProfileRepository>.value(
          value: dependencies.profileRepository,
        ),
        Provider<SettingsRepository>.value(
          value: dependencies.settingsRepository,
        ),
        Provider<SubscriptionsRepository>.value(
          value: dependencies.subscriptionsRepository,
        ),
        ChangeNotifierProvider(
          create: (_) => AppPreferencesController(
            settingsRepository: dependencies.settingsRepository,
          )..load(),
        ),
      ],
      child: child,
    );
  }
}
