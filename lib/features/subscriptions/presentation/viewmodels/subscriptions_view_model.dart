import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_subscriptions.dart';

enum SubscriptionDisplayMode { grid, list }

class SubscriptionsViewModel extends ChangeNotifier {
  SubscriptionsViewModel({
    required GetSubscriptionsUseCase getSubscriptions,
  }) : _getSubscriptions = getSubscriptions;

  final GetSubscriptionsUseCase _getSubscriptions;

  bool _isLoading = false;
  String? _errorMessage;
  List<Subscription> _subscriptions = const [];
  SubscriptionDisplayMode _displayMode = SubscriptionDisplayMode.grid;
  SubscriptionCategory? _selectedCategory;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Subscription> get subscriptions => _subscriptions;
  SubscriptionDisplayMode get displayMode => _displayMode;
  SubscriptionCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get isGridMode => _displayMode == SubscriptionDisplayMode.grid;
  bool get isListMode => _displayMode == SubscriptionDisplayMode.list;

  List<SubscriptionCategory> get filterCategories => const [
    SubscriptionCategory.dataPlan,
    SubscriptionCategory.apps,
    SubscriptionCategory.tools,
    SubscriptionCategory.vehicle,
  ];

  int get totalSubscriptions => _subscriptions.length;

  List<CategorySummary> get categorySummaries {
    return SubscriptionCategory.values
        .map(
          (category) => CategorySummary(
            category: category,
            count: _subscriptions
                .where((subscription) => subscription.category == category)
                .length,
          ),
        )
        .toList(growable: false);
  }

  List<Subscription> get filteredSubscriptions {
    final query = _searchQuery.trim().toLowerCase();
    return _subscriptions.where((subscription) {
      final matchesCategory = _selectedCategory == null
          ? true
          : subscription.category == _selectedCategory;
      final matchesQuery = query.isEmpty
          ? true
          : subscription.name.toLowerCase().contains(query) ||
              subscription.categoryLabel.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  List<CategoryGroup> get groupedSubscriptions {
    final groups = <CategoryGroup>[];
    final filtered = filteredSubscriptions;
    for (final category in SubscriptionCategory.values) {
      final matches = filtered
          .where((subscription) => subscription.category == category)
          .toList(growable: false);
      if (matches.isNotEmpty) {
        groups.add(CategoryGroup(category: category, subscriptions: matches));
      }
    }
    return groups;
  }

  Future<void> load({
    SubscriptionDisplayMode? displayMode,
    SubscriptionCategory? selectedCategory,
    bool resetSelectedCategory = false,
  }) async {
    if (displayMode != null) {
      _displayMode = displayMode;
    }
    if (resetSelectedCategory) {
      _selectedCategory = null;
    } else if (selectedCategory != null) {
      _selectedCategory = selectedCategory;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscriptions = await _getSubscriptions();
    } catch (_) {
      _errorMessage = 'Unable to load subscriptions right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDisplayMode(SubscriptionDisplayMode value) {
    if (_displayMode == value) {
      return;
    }

    _displayMode = value;
    notifyListeners();
  }

  void selectCategory(SubscriptionCategory? category) {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  int countForCategory(SubscriptionCategory? category) {
    if (category == null) {
      return totalSubscriptions;
    }

    return _subscriptions
        .where((subscription) => subscription.category == category)
        .length;
  }
}

class CategorySummary {
  const CategorySummary({
    required this.category,
    required this.count,
  });

  final SubscriptionCategory category;
  final int count;
}

class CategoryGroup {
  const CategoryGroup({
    required this.category,
    required this.subscriptions,
  });

  final SubscriptionCategory category;
  final List<Subscription> subscriptions;
}
