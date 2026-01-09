import 'package:flutter/material.dart';
import '../../../check_in/domain/entities/check_in_entity.dart';
import '../../../check_in/domain/usecases/get_patient_check_ins_usecase.dart';

class PatientDetailViewModel extends ChangeNotifier {
  final GetPatientCheckInsUseCase getPatientCheckInsUseCase;

  PatientDetailViewModel({required this.getPatientCheckInsUseCase});

  List<CheckInEntity> history = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchHistory(String patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getPatientCheckInsUseCase(patientId);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoading = false;
        notifyListeners();
      },
      (checkIns) {
        history = checkIns;
        isLoading = false;
        notifyListeners();
      },
    );
  }
}
