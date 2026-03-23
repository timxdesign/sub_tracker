import '../models/subscription.dart';
import '../repositories/subscriptions_repository.dart';

class GetUpcomingPaymentsUseCase {
  const GetUpcomingPaymentsUseCase(this._repository);

  final SubscriptionsRepository _repository;

  Future<List<Subscription>> call() async {
    final subscriptions = await _repository.getSubscriptions();
    return subscriptions
        .where((subscription) => !subscription.isExpired)
        .toList(growable: false);
  }
}
