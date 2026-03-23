import 'package:flutter/foundation.dart';

import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_upcoming_payments.dart';

class UpcomingPaymentsViewModel extends ChangeNotifier {
  UpcomingPaymentsViewModel({
    required GetUpcomingPaymentsUseCase getUpcomingPayments,
  }) : _getUpcomingPayments = getUpcomingPayments;

  final GetUpcomingPaymentsUseCase _getUpcomingPayments;

  bool _isLoading = false;
  String? _errorMessage;
  List<Subscription> _payments = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Subscription> get payments => _payments;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await _getUpcomingPayments();
    } catch (_) {
      _errorMessage = 'Unable to load upcoming payments right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
