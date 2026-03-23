import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl({required OnboardingLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<void> completeOnboarding() {
    return _localDataSource.completeOnboarding();
  }

  @override
  Future<bool> hasCompletedOnboarding() {
    return _localDataSource.hasCompletedOnboarding();
  }
}
