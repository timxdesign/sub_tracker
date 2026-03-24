import '../../../../core/viewmodels/app_view_model.dart';
import '../../../profile/domain/models/profile.dart';
import '../../../profile/domain/usecases/get_stored_profile.dart';
import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscriptions.dart';

class HomeDashboardViewModel extends AppViewModel {
  HomeDashboardViewModel({
    required GetStoredProfileUseCase getStoredProfile,
    required GetSubscriptionsUseCase getSubscriptions,
  }) : _getStoredProfile = getStoredProfile,
       _getSubscriptions = getSubscriptions;

  final GetStoredProfileUseCase _getStoredProfile;
  final GetSubscriptionsUseCase _getSubscriptions;

  bool _isLoading = false;
  String? _errorMessage;
  String _firstName = 'there';
  List<Subscription> _subscriptions = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get firstName => _firstName;
  List<Subscription> get subscriptions => _subscriptions;
  List<Subscription> get upcomingPreview => _subscriptions
      .where((subscription) => !subscription.isExpired)
      .take(3)
      .toList(growable: false);

  int get activeCount =>
      _subscriptions.where((subscription) => !subscription.isExpired).length;

  int get expiredCount =>
      _subscriptions.where((subscription) => subscription.isExpired).length;

  List<Subscription> get expiringSoonSubscriptions {
    return _subscriptions
        .where((subscription) => subscription.isExpiringSoon)
        .toList(growable: false);
  }

  int get expiringSoonCount => expiringSoonSubscriptions.length;

  double get expiringSoonTotal {
    return expiringSoonSubscriptions.fold<double>(
      0,
      (total, subscription) => total + subscription.price,
    );
  }

  List<DashboardCategoryPreview> get categoryPreview {
    final summaries = <DashboardCategoryPreview>[];
    for (final category in SubscriptionCategory.values) {
      final count = _subscriptions
          .where((subscription) => subscription.category == category)
          .length;
      if (count > 0) {
        summaries.add(
          DashboardCategoryPreview(category: category, count: count),
        );
      }
    }

    if (summaries.length >= 2) {
      return summaries.take(2).toList(growable: false);
    }

    for (final category in SubscriptionCategory.values) {
      final alreadyAdded = summaries.any(
        (summary) => summary.category == category,
      );
      if (!alreadyAdded) {
        summaries.add(DashboardCategoryPreview(category: category, count: 0));
      }
      if (summaries.length == 2) {
        break;
      }
    }

    return summaries;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object?>([
        _getStoredProfile(),
        _getSubscriptions(),
      ]);
      final storedProfile = results[0] as Profile?;
      _subscriptions = results[1] as List<Subscription>;
      _firstName = 'there';

      final fullName = storedProfile?.fullName;
      if (fullName != null && fullName.trim().isNotEmpty) {
        _firstName = fullName.trim().split(RegExp(r'\s+')).first;
      }
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'HomeDashboardViewModel.load');
      _errorMessage = 'Unable to load your dashboard right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class DashboardCategoryPreview {
  const DashboardCategoryPreview({required this.category, required this.count});

  final SubscriptionCategory category;
  final int count;
}
