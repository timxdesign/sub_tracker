import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../dto/subscription_dto.dart';

class SubscriptionsLocalDataSource {
  const SubscriptionsLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<SubscriptionDto>> getSubscriptions() async {
    return (await _database.select(_database.subscriptionRecords).get())
        .map(
          (subscription) => SubscriptionDto(
            id: subscription.id,
            name: subscription.name,
            category: subscription.category,
            price: subscription.price,
            currencyCode: subscription.currencyCode,
            billingCycle: subscription.billingCycle,
            nextBillingDate: subscription.nextBillingDate,
            createdAt: subscription.createdAt,
            description: subscription.description,
            serviceProvider: subscription.serviceProvider,
            website: subscription.website,
            startDate: subscription.startDate,
          ),
        )
        .where((subscription) => subscription.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> saveSubscriptions(List<SubscriptionDto> subscriptions) {
    return _database.transaction(() async {
      await clearSubscriptions();
      if (subscriptions.isEmpty) {
        return;
      }

      await _database.batch((batch) {
        batch.insertAll(
          _database.subscriptionRecords,
          subscriptions
              .map(
                (subscription) => SubscriptionRecordsCompanion.insert(
                  id: subscription.id,
                  name: subscription.name,
                  category: subscription.category,
                  price: subscription.price,
                  currencyCode: subscription.currencyCode,
                  billingCycle: subscription.billingCycle,
                  nextBillingDate: subscription.nextBillingDate,
                  createdAt: subscription.createdAt,
                  description: Value(subscription.description),
                  serviceProvider: Value(subscription.serviceProvider),
                  website: Value(subscription.website),
                  startDate: Value(subscription.startDate),
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<void> clearSubscriptions() {
    return _database.delete(_database.subscriptionRecords).go();
  }
}
