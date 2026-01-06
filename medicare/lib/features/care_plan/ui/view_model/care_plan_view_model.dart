import 'package:flutter/material.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/usecases/create_care_plan_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/update_care_plan_usecase.dart';

class CarePlanViewModel extends ChangeNotifier {
  final CreateCarePlanUseCase createCarePlanUseCase;
  final GetPlansUseCase getPlansUseCase;
  final UpdateCarePlanUseCase updateCarePlanUseCase;

  CarePlanViewModel({
    required this.createCarePlanUseCase,
    required this.getPlansUseCase,
    required this.updateCarePlanUseCase,
  });

  bool isLoading = false;
  String? errorMessage;
  List<CarePlanEntity> plans = [];

  // ... fetchPlans ...

  Future<void> fetchPlans(String userId, String userType) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result =
        userType ==
            'medico' // Considering 'medico' as the type string
        ? await getPlansUseCase.byDoctorId(userId)
        : await getPlansUseCase.byPatientId(userId);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoading = false;
        notifyListeners();
      },
      (fetchedPlans) {
        plans = fetchedPlans;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createPlan(CarePlanEntity plan) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await createCarePlanUseCase(plan);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoading = false;
        notifyListeners();
      },
      (_) {
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> updatePlan(CarePlanEntity plan) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await updateCarePlanUseCase(plan);

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}
