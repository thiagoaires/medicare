import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_stats.dart';
import '../../domain/usecases/get_doctor_stats_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final GetDoctorStatsUseCase?
  getDoctorStatsUseCase; // Optional for Patient flavor, but we can standardise

  HomeViewModel({this.getDoctorStatsUseCase});

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardStats? _stats;
  DashboardStats? get stats => _stats;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> fetchDoctorStats(String doctorId) async {
    if (getDoctorStatsUseCase == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await getDoctorStatsUseCase!(doctorId);

    result.fold(
      (failure) {
        // Handle error if needed, maybe show snackbar via UI listener
        // Handle error if needed, maybe show snackbar via UI listener
        // print('Error fetching stats: ${failure.message}');
        _isLoading = false;
        notifyListeners();
      },
      (stats) {
        _stats = stats;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void logout() {
    _currentIndex = 0;
    _stats = null;
    notifyListeners();
  }
}
