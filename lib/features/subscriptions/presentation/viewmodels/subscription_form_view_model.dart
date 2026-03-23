import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/save_subscription.dart';

class SubscriptionFormViewModel extends ChangeNotifier {
  SubscriptionFormViewModel({
    required SaveSubscriptionUseCase saveSubscription,
  }) : _saveSubscription = saveSubscription;

  final SaveSubscriptionUseCase _saveSubscription;

  String _name = '';
  SubscriptionCategory? _category;
  String _price = '';
  String _description = '';
  SubscriptionBillingCycle _billingCycle = SubscriptionBillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  bool _isSubmitting = false;
  bool _showErrors = false;

  String get name => _name;
  SubscriptionCategory? get category => _category;
  String get price => _price;
  String get description => _description;
  SubscriptionBillingCycle get billingCycle => _billingCycle;
  DateTime get nextBillingDate => _nextBillingDate;
  bool get isSubmitting => _isSubmitting;

  String? get nameError =>
      _showErrors && _name.trim().isEmpty ? 'Enter a subscription name' : null;

  String? get categoryError =>
      _showErrors && _category == null ? 'Select a category' : null;

  String? get priceError {
    if (!_showErrors) {
      return null;
    }

    final amount = double.tryParse(_price.trim());
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
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

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateBillingCycle(SubscriptionBillingCycle value) {
    _billingCycle = value;
    notifyListeners();
  }

  void updateNextBillingDate(DateTime value) {
    _nextBillingDate = value;
    notifyListeners();
  }

  Future<String?> submit() async {
    _showErrors = true;
    notifyListeners();

    final amount = double.tryParse(_price.trim());
    if (_name.trim().isEmpty ||
        _category == null ||
        amount == null ||
        amount <= 0) {
      return null;
    }

    if (_isSubmitting) {
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    final subscriptionId =
        '${DateTime.now().microsecondsSinceEpoch}-${_name.trim().toLowerCase().replaceAll(' ', '-')}';

    try {
      await _saveSubscription(
        Subscription(
          id: subscriptionId,
          name: _name.trim(),
          category: _category!,
          price: amount,
          currencyCode: 'NGN',
          billingCycle: _billingCycle,
          nextBillingDate: _nextBillingDate,
          createdAt: DateTime.now(),
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
