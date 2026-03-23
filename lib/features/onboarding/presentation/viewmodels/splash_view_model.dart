import 'package:flutter/foundation.dart';

import '../../../../app/router/route_names.dart';
import '../../../profile/domain/usecases/get_stored_profile.dart';
import '../../domain/usecases/get_onboarding_status.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel({
    required GetOnboardingStatusUseCase getOnboardingStatus,
    required GetStoredProfileUseCase getStoredProfile,
  })  : _getOnboardingStatus = getOnboardingStatus,
        _getStoredProfile = getStoredProfile;

  final GetOnboardingStatusUseCase _getOnboardingStatus;
  final GetStoredProfileUseCase _getStoredProfile;

  Future<String> resolveNextRoute() async {
    final profile = await _getStoredProfile();
    if (profile != null) {
      return AppRoutes.home;
    }

    final hasCompletedOnboarding = await _getOnboardingStatus();
    return hasCompletedOnboarding
        ? AppRoutes.createProfile
        : AppRoutes.welcome;
  }
}
