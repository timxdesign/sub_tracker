import '../../../../core/viewmodels/app_view_model.dart';
import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscription.dart';
import '../../domain/usecases/save_subscription.dart';

class SubscriptionDetailsViewModel extends AppViewModel {
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

    try {
      _subscription = await _getSubscription(id);
    } catch (error, stackTrace) {
      reportError(
        error,
        stackTrace,
        context: 'SubscriptionDetailsViewModel.load',
      );
      _subscription = null;
    }

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
    } catch (error, stackTrace) {
      reportError(
        error,
        stackTrace,
        context: 'SubscriptionDetailsViewModel.renew',
      );
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
