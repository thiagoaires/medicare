import 'package:flutter/material.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/repositories/care_plan_repository.dart';
import '../../domain/usecases/create_care_plan_usecase.dart';
import '../../domain/usecases/get_plans_usecase.dart';
import '../../domain/usecases/update_care_plan_usecase.dart';
import '../../../auth/domain/usecases/search_patients_usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/notification_service.dart';

class CarePlanViewModel extends ChangeNotifier {
  final CreateCarePlanUseCase createCarePlanUseCase;
  final GetPlansUseCase getPlansUseCase;
  final UpdateCarePlanUseCase updateCarePlanUseCase;
  final SearchPatientsUseCase searchPatientsUseCase;
  final CarePlanRepository carePlanRepository;

  CarePlanViewModel({
    required this.createCarePlanUseCase,
    required this.getPlansUseCase,
    required this.updateCarePlanUseCase,
    required this.searchPatientsUseCase,
    required this.carePlanRepository,
  });

  bool isLoading = false;
  String? errorMessage;
  List<CarePlanEntity> plans = [];

  Future<List<UserEntity>> searchPatients(String term) async {
    final result = await searchPatientsUseCase(term);
    return result.fold((failure) => [], (users) => users);
  }

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

  // --- Quick Task Logic ---

  Map<String, int> dailyTaskCounts = {};
  Map<String, int> dailyGoals = {};

  void calculateGoals(List<CarePlanEntity> plans) {
    for (final plan in plans) {
      // Logic for Frequency: Assuming 'frequency' field exists in Entity or we use a placeholder logic as per prompt.
      // Prompt says: "Se frequency do plano for em horas (ex: 8h), calcule a meta do dia: (24 / frequency).floor(). Se frequency for 0 ou nulo, assuma meta = 1."
      int goal = 1;
      // TODO: Implement frequency logic if field exists. For now default to 1.
      dailyGoals[plan.id] = goal;
    }
    notifyListeners();
  }

  Future<void> loadTaskLogsForPlans(List<CarePlanEntity> currentPlans) async {
    for (final plan in currentPlans) {
      final result = await carePlanRepository.getTodaysTaskCount(plan.id);
      result.fold(
        (failure) {
          // Ignore failures for logs to not block main UI
          debugPrint('Error fetching logs for ${plan.id}: ${failure.message}');
        },
        (count) {
          dailyTaskCounts[plan.id] = count;
        },
      );
    }
    calculateGoals(currentPlans);
    notifyListeners();
  }

  Future<void> registerExecution(CarePlanEntity plan) async {
    final result = await carePlanRepository.registerExecution(plan);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        // Success.
        final currentCount = dailyTaskCounts[plan.id] ?? 0;
        dailyTaskCounts[plan.id] = currentCount + 1;
        notifyListeners();
      },
    );
  }
}
