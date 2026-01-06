import 'package:flutter/material.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/usecases/create_care_plan_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';

class CarePlanViewModel extends ChangeNotifier {
  final CreateCarePlanUseCase createCarePlanUseCase;
  final GetPlansUseCase getPlansUseCase;

  CarePlanViewModel({
    required this.createCarePlanUseCase,
    required this.getPlansUseCase,
  });

  bool isLoading = false;
  String? errorMessage;
  List<CarePlanEntity> plans = [];

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
        // Success
        isLoading = false;
        // Optionally fetch plans again if we knew the user type/id here,
        // OR add to list manually if we returned the created object (but usecase returns Unit).
        // For now, let's just notify success logic in UI or refresh manually.
        notifyListeners();
      },
    );
  }
}
