import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/json_preferences_store.dart';
import '../dto/subscription_dto.dart';

class SubscriptionsLocalDataSource {
  const SubscriptionsLocalDataSource(this._store);

  final JsonPreferencesStore _store;

  Future<List<SubscriptionDto>> getSubscriptions() async {
    return _store
        .readList(StorageKeys.subscriptions)
        .map(SubscriptionDto.fromJson)
        .where((subscription) => subscription.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> saveSubscriptions(List<SubscriptionDto> subscriptions) {
    return _store.writeList(
      StorageKeys.subscriptions,
      subscriptions.map((subscription) => subscription.toJson()).toList(),
    );
  }
}
