import '../models/subscription.dart';
import '../repositories/subscriptions_repository.dart';

class SaveSubscriptionUseCase {
  const SaveSubscriptionUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<void> call(Subscription subscription) {
    return _repository.saveSubscription(subscription);
  }
}
