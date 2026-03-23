import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscription.dart';

class SubscriptionDetailsViewModel extends ChangeNotifier {
  SubscriptionDetailsViewModel({
    required GetSubscriptionUseCase getSubscription,
  }) : _getSubscription = getSubscription;

  final GetSubscriptionUseCase _getSubscription;

  bool _isLoading = false;
  Subscription? _subscription;

  bool get isLoading => _isLoading;
  Subscription? get subscription => _subscription;

  Future<void> load(String id) async {
    _isLoading = true;
    notifyListeners();

    _subscription = await _getSubscription(id);

    _isLoading = false;
    notifyListeners();
  }
}
