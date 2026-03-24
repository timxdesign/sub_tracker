import '../../../../core/viewmodels/app_view_model.dart';
import '../../domain/models/subscription.dart';
import '../../domain/usecases/get_upcoming_payments.dart';

class UpcomingPaymentsViewModel extends AppViewModel {
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
    } catch (error, stackTrace) {
      reportError(error, stackTrace, context: 'UpcomingPaymentsViewModel.load');
      _errorMessage = 'Unable to load upcoming payments right now.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
