import '../../domain/models/subscription.dart';
import '../../domain/repositories/subscriptions_repository.dart';
import '../datasources/subscriptions_local_data_source.dart';
import '../datasources/subscriptions_remote_data_source.dart';
import '../dto/subscription_dto.dart';

class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  SubscriptionsRepositoryImpl({
    required SubscriptionsLocalDataSource localDataSource,
    required SubscriptionsRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final SubscriptionsLocalDataSource _localDataSource;
  final SubscriptionsRemoteDataSource _remoteDataSource;

  @override
  Future<Subscription?> getSubscriptionById(String id) async {
    final subscriptions = await getSubscriptions();
    for (final subscription in subscriptions) {
      if (subscription.id == id) {
        return subscription;
      }
    }

    return null;
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final localSubscriptions = await _localDataSource.getSubscriptions();
    if (localSubscriptions.isNotEmpty || !_remoteDataSource.isConfigured) {
      return _mapToDomain(localSubscriptions);
    }

    final remoteSubscriptions = await _remoteDataSource.fetchSubscriptions();
    if (remoteSubscriptions.isNotEmpty) {
      await _localDataSource.saveSubscriptions(remoteSubscriptions);
      return _mapToDomain(remoteSubscriptions);
    }

    return const [];
  }

  @override
  Future<void> saveSubscription(Subscription subscription) async {
    final subscriptions = (await _localDataSource.getSubscriptions()).toList();
    final dto = SubscriptionDto.fromDomain(subscription);
    final index = subscriptions.indexWhere(
      (existingSubscription) => existingSubscription.id == subscription.id,
    );

    if (index >= 0) {
      subscriptions[index] = dto;
    } else {
      subscriptions.add(dto);
    }

    await _localDataSource.saveSubscriptions(subscriptions);
    await _remoteDataSource.upsertSubscription(dto);
  }

  List<Subscription> _mapToDomain(List<SubscriptionDto> subscriptions) {
    final mapped = subscriptions
        .map((subscription) => subscription.toDomain())
        .toList();
    mapped.sort(
      (left, right) => left.nextBillingDate.compareTo(right.nextBillingDate),
    );
    return mapped;
  }
}
