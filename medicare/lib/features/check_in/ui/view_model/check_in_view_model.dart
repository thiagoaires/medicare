import 'package:flutter/material.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/usecases/get_plan_history_usecase.dart';
import '../../domain/usecases/perform_check_in_usecase.dart';

class CheckInViewModel extends ChangeNotifier {
  final PerformCheckInUseCase performCheckInUseCase;
  final GetPlanHistoryUseCase getPlanHistoryUseCase;

  CheckInViewModel({
    required this.performCheckInUseCase,
    required this.getPlanHistoryUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckedInToday = false;
  bool get isCheckedInToday => _isCheckedInToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CheckInEntity> _history = [];
  List<CheckInEntity> get history => _history;

  Future<void> checkStatus(String planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getPlanHistoryUseCase(planId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (fetchedHistory) {
        _history = fetchedHistory;

        // Verificar se tem check-in hoje
        // Verificar se tem check-in hoje
        final today = DateTime.now();

        bool isSameDay(DateTime a, DateTime b) {
          final localA = a.toLocal();
          final localB = b.toLocal();
          return localA.year == localB.year &&
              localA.month == localB.month &&
              localA.day == localB.day;
        }

        _isCheckedInToday = fetchedHistory.any((checkIn) {
          return isSameDay(checkIn.date, today);
        });

        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> doCheckIn(String planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await performCheckInUseCase(planId, null);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        // Sucesso
        _isCheckedInToday = true;
        _isLoading = false;
        notifyListeners();
        // Refresh history to include the new one (optional immediately, but good for UI consistency)
        checkStatus(planId);
        return true;
      },
    );
  }
}
