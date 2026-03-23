import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class GetStoredProfileUseCase {
  const GetStoredProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile?> call() => _repository.getStoredProfile();
}
