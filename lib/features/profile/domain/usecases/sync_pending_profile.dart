import '../repositories/profile_repository.dart';

class SyncPendingProfileUseCase {
  const SyncPendingProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() => _repository.syncPendingProfile();
}
