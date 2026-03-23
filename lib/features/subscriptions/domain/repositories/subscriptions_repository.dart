import '../models/subscription.dart';

abstract interface class SubscriptionsRepository {
  Future<List<Subscription>> getSubscriptions();

  Future<Subscription?> getSubscriptionById(String id);

  Future<void> saveSubscription(Subscription subscription);
}
