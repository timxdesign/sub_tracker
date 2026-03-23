import '../models/subscription.dart';
import '../repositories/subscriptions_repository.dart';

class GetSubscriptionsUseCase {
  const GetSubscriptionsUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<List<Subscription>> call() => _repository.getSubscriptions();
}
