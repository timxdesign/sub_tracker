import 'package:flutter/foundation.dart';

import '../../domain/usecases/complete_onboarding.dart';

class GetStartedViewModel extends ChangeNotifier {
  GetStartedViewModel({
    required CompleteOnboardingUseCase completeOnboarding,
  }) : _completeOnboarding = completeOnboarding;

  final CompleteOnboardingUseCase _completeOnboarding;

  Future<void> start() => _completeOnboarding();
}
