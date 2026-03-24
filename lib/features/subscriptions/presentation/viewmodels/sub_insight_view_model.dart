import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscriptions.dart';

class SubInsightViewModel extends ChangeNotifier {
  SubInsightViewModel({
    required GetSubscriptionsUseCase getSubscriptions,
    DateTime Function()? now,
  }) : _getSubscriptions = getSubscriptions,
       _now = now ?? DateTime.now,
       _selectedMonth = _monthOnly((now ?? DateTime.now)());

  final GetSubscriptionsUseCase _getSubscriptions;
  final DateTime Function() _now;
  final DateTime _selectedMonth;

  bool _isLoading = false;
  String? _errorMessage;
  List<Subscription> _subscriptions = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Subscription> get subscriptions => _subscriptions;
  bool get hasSubscriptions => _subscriptions.isNotEmpty;
  DateTime get selectedMonth => _selectedMonth;
  String get selectedMonthLabel => _monthLabels[_selectedMonth.month - 1];
  int get totalSubscriptions => _subscriptions.length;

  double get spendForSelectedMonth {
    return _subscriptions
        .where(
          (subscription) =>
              _isSameMonth(subscription.nextBillingDate, _selectedMonth),
        )
        .fold<double>(0, (total, subscription) => total + subscription.price);
  }

  double get spendChangeFromPreviousMonth {
    return spendForSelectedMonth -
        _spendForMonth(_previousMonth(_selectedMonth));
  }

  int get newSubscriptionsCount {
    return _subscriptions
        .where(
          (subscription) =>
              _isSameMonth(subscription.createdAt, _selectedMonth),
        )
        .length;
  }

  int get cancelledSubscriptionsCount {
    return _subscriptions
        .where(
          (subscription) =>
              _isExpired(subscription) &&
              _isSameMonth(subscription.nextBillingDate, _selectedMonth),
        )
        .length;
  }

  List<InsightCategorySummary> get categorySummaries {
    return SubscriptionCategory.values
        .map((category) {
          return InsightCategorySummary(
            category: category,
            count: _subscriptions
                .where((subscription) => subscription.category == category)
                .length,
          );
        })
        .toList(growable: false);
  }

  List<InsightCategorySummary> get nonZeroCategorySummaries {
    return categorySummaries
        .where((summary) => summary.count > 0)
        .toList(growable: false);
  }

  InsightCategorySummary? get topCategory {
    final summaries = nonZeroCategorySummaries.toList(growable: false);
    if (summaries.isEmpty) {
      return null;
    }

    summaries.sort((left, right) {
      final countOrder = right.count.compareTo(left.count);
      if (countOrder != 0) {
        return countOrder;
      }

      return SubscriptionCategory.values
          .indexOf(left.category)
          .compareTo(SubscriptionCategory.values.indexOf(right.category));
    });
    return summaries.first;
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscriptions = await _getSubscriptions();
    } catch (_) {
      _errorMessage = 'Unable to load subscription insights right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _spendForMonth(DateTime month) {
    return _subscriptions
        .where(
          (subscription) => _isSameMonth(subscription.nextBillingDate, month),
        )
        .fold<double>(0, (total, subscription) => total + subscription.price);
  }

  bool _isExpired(Subscription subscription) {
    return _dateOnly(subscription.nextBillingDate).isBefore(_dateOnly(_now()));
  }
}

class InsightCategorySummary {
  const InsightCategorySummary({required this.category, required this.count});

  final SubscriptionCategory category;
  final int count;
}

const _monthLabels = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

DateTime _monthOnly(DateTime value) => DateTime(value.year, value.month);

DateTime _previousMonth(DateTime value) =>
    DateTime(value.year, value.month - 1);

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _isSameMonth(DateTime value, DateTime month) {
  return value.year == month.year && value.month == month.month;
}
