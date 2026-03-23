import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  const CreateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call({
    required String fullName,
    required String email,
  }) {
    return _repository.createProfile(fullName: fullName, email: email);
  }
}
