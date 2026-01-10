import 'package:flutter/material.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/usecases/create_care_plan_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/update_care_plan_usecase.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/notification_service.dart';

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

  // --- Notification Logic ---

  Map<String, bool> notificationStatus = {};

  Future<void> loadNotificationPreferences(
    NotificationService notificationService,
    List<CarePlanEntity> currentPlans,
  ) async {
    for (final plan in currentPlans) {
      notificationStatus[plan.id] = notificationService.isNotificationEnabled(
        plan.id,
      );
    }
    notifyListeners();
  }

  Future<void> toggleNotification(
    CarePlanEntity plan,
    NotificationService notificationService,
  ) async {
    final currentStatus = notificationStatus[plan.id] ?? true;
    final newStatus = !currentStatus;

    if (newStatus) {
      // Check Permission before enabling
      final status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          // Permission denied, do not enable
          // Could set an error message or handle in UI
          return;
        }
      }
    }

    // Update State
    notificationStatus[plan.id] = newStatus;
    notifyListeners(); // Immediate UI update

    // Persist and Schedule/Cancel
    await notificationService.setNotificationEnabled(plan.id, newStatus);

    if (newStatus) {
      await notificationService.scheduleFromPlan(plan);
    } else {
      await notificationService.cancelForPlan(plan.id);
    }
  }
}
