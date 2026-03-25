import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/save_subscription.dart';

class SubscriptionFormViewModel extends ChangeNotifier {
  SubscriptionFormViewModel({
    required SaveSubscriptionUseCase saveSubscription,
    String defaultCurrencyCode = 'NGN',
  }) : _saveSubscription = saveSubscription,
       _defaultCurrencyCode = defaultCurrencyCode;

  final SaveSubscriptionUseCase _saveSubscription;
  final String _defaultCurrencyCode;

  String _name = '';
  SubscriptionCategory? _category;
  String _price = '';
  String _serviceProvider = '';
  String _website = '';
  String _description = '';
  SubscriptionBillingCycle _billingCycle = SubscriptionBillingCycle.monthly;
  DateTime? _startDate;
  DateTime? _nextBillingDate;
  bool _hasCustomBillingDate = false;
  bool _isSubmitting = false;
  bool _showErrors = false;

  String get name => _name;
  SubscriptionCategory? get category => _category;
  String get price => _price;
  String get currencyCode => _defaultCurrencyCode;
  String get serviceProvider => _serviceProvider;
  String get website => _website;
  String get description => _description;
  SubscriptionBillingCycle get billingCycle => _billingCycle;
  DateTime? get startDate => _startDate;
  DateTime? get nextBillingDate => _nextBillingDate;
  bool get isSubmitting => _isSubmitting;
  bool get canSubmit => _isFormValid;

  bool get _isFormValid {
    final amount = _parseAmount(_price);
    final startDate = _startDate;
    final billingDate = _nextBillingDate;

    return _name.trim().isNotEmpty &&
        _category != null &&
        amount != null &&
        amount > 0 &&
        startDate != null &&
        billingDate != null &&
        !billingDate.isBefore(startDate);
  }

  String? get nameError =>
      _showErrors && _name.trim().isEmpty ? 'Enter a subscription name' : null;

  String? get categoryError =>
      _showErrors && _category == null ? 'Select a category' : null;

  String? get priceError {
    if (!_showErrors) {
      return null;
    }

    final amount = _parseAmount(_price);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }

    return null;
  }

  String? get startDateError =>
      _showErrors && _startDate == null ? 'Select a start date' : null;

  String? get nextBillingDateError {
    if (!_showErrors) {
      return null;
    }

    final billingDate = _nextBillingDate;
    if (billingDate == null) {
      return 'Enter a billing date';
    }

    final startDate = _startDate;
    if (startDate != null && billingDate.isBefore(startDate)) {
      return 'Billing date must be after start date';
    }

    return null;
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateCategory(SubscriptionCategory value) {
    _category = value;
    notifyListeners();
  }

  void updatePrice(String value) {
    _price = value;
    notifyListeners();
  }

  void updateServiceProvider(String value) {
    _serviceProvider = value;
    notifyListeners();
  }

  void updateWebsite(String value) {
    _website = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateBillingCycle(SubscriptionBillingCycle value) {
    _billingCycle = value;
    _hasCustomBillingDate = false;
    _nextBillingDate = _defaultNextBillingDate(
      startDate: _startDate,
      billingCycle: value,
    );
    notifyListeners();
  }

  void updateStartDate(DateTime value) {
    _startDate = value;
    if (!_hasCustomBillingDate) {
      _nextBillingDate = _defaultNextBillingDate(
        startDate: value,
        billingCycle: _billingCycle,
      );
    } else if (_nextBillingDate != null && _nextBillingDate!.isBefore(value)) {
      _nextBillingDate = null;
      _hasCustomBillingDate = false;
    }
    notifyListeners();
  }

  void updateNextBillingDate(DateTime value) {
    _nextBillingDate = value;
    _hasCustomBillingDate = true;
    notifyListeners();
  }

  Future<String?> submit() async {
    _showErrors = true;
    notifyListeners();

    if (!_isFormValid) {
      return null;
    }

    if (_isSubmitting) {
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    final normalizedName = _name.trim();
    final amount = _parseAmount(_price)!;
    final subscriptionId =
        '${DateTime.now().microsecondsSinceEpoch}-${normalizedName.toLowerCase().replaceAll(' ', '-')}';

    try {
      await _saveSubscription(
        Subscription(
          id: subscriptionId,
          name: normalizedName,
          category: _category!,
          price: amount,
          currencyCode: _defaultCurrencyCode,
          billingCycle: _billingCycle,
          nextBillingDate: _nextBillingDate!,
          createdAt: DateTime.now(),
          startDate: _startDate,
          serviceProvider: _serviceProvider.trim(),
          website: _website.trim(),
          description: _description.trim(),
        ),
      );
      return subscriptionId;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

double? _parseAmount(String value) {
  final sanitized = value.replaceAll(',', '').trim();
  return double.tryParse(sanitized);
}

DateTime? _defaultNextBillingDate({
  required DateTime? startDate,
  required SubscriptionBillingCycle billingCycle,
}) {
  if (startDate == null) {
    return null;
  }

  return switch (billingCycle) {
    SubscriptionBillingCycle.monthly => billingCycle.advanceDate(startDate),
    SubscriptionBillingCycle.yearly => billingCycle.advanceDate(startDate),
    SubscriptionBillingCycle.custom => null,
    SubscriptionBillingCycle.lifetime => startDate,
  };
}
