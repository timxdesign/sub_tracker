import '../models/subscription.dart';
import '../repositories/subscriptions_repository.dart';

class GetSubscriptionUseCase {
  const GetSubscriptionUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<Subscription?> call(String id) {
    return _repository.getSubscriptionById(id);
  }
}
