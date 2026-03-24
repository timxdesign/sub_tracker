import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscription.dart';
import '../../domain/usecases/save_subscription.dart';

class SubscriptionDetailsViewModel extends ChangeNotifier {
  SubscriptionDetailsViewModel({
    required GetSubscriptionUseCase getSubscription,
    required SaveSubscriptionUseCase saveSubscription,
  }) : _getSubscription = getSubscription,
       _saveSubscription = saveSubscription;

  final GetSubscriptionUseCase _getSubscription;
  final SaveSubscriptionUseCase _saveSubscription;

  String? _subscriptionId;
  bool _isLoading = false;
  bool _isUpdating = false;
  Subscription? _subscription;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  Subscription? get subscription => _subscription;

  Future<void> load(String id) async {
    _subscriptionId = id;
    _isLoading = true;
    notifyListeners();

    _subscription = await _getSubscription(id);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> renew() async {
    final current = _subscription;
    if (current == null || !current.supportsRenewal || _isUpdating) {
      return;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      await _saveSubscription(
        current.copyWith(nextBillingDate: current.renewedBillingDate),
      );
      if (_subscriptionId != null) {
        _subscription = await _getSubscription(_subscriptionId!);
      }
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
