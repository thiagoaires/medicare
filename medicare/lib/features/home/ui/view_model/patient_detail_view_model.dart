import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../check_in/domain/entities/check_in_entity.dart';
import '../../../check_in/domain/usecases/get_patient_check_ins_usecase.dart';
import '../../../care_plan/domain/repositories/care_plan_repository.dart';
import '../../../care_plan/infra/models/task_log.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';

class PatientDetailViewModel extends ChangeNotifier {
  final GetPatientCheckInsUseCase getPatientCheckInsUseCase;
  final CarePlanRepository carePlanRepository;

  PatientDetailViewModel({
    required this.getPatientCheckInsUseCase,
    required this.carePlanRepository,
  });

  List<CheckInEntity> history = [];
  bool isLoading = false;
  String? errorMessage;

  // Adherence Data
  // planId -> count
  Map<String, int> adherenceCounts = {};
  // planId -> goal per day (freq) -> total goal for 7 days
  Map<String, int> adherenceGoals = {};
  double overallAdherence = 0.0;
  List<CarePlanEntity> patientPlans = [];

  Future<void> fetchHistory(String patientId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // Parallel execution: History + Adherence
    await Future.wait([_loadHistory(patientId), loadAdherenceData(patientId)]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadHistory(String patientId) async {
    final result = await getPatientCheckInsUseCase(patientId);
    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (checkIns) {
        history = checkIns;
      },
    );
  }

  Future<void> loadAdherenceData(String patientId) async {
    // 1. We need the plans to calculate goals (frequency)
    // We can assume we need to fetch them. Does repository allow fetching by patientId?
    // Repository method 'getPlansByPatientId' exists in remote source but usually exposed via UseCase 'GetPlansUseCase'.
    // However, repository implementation might have it or we access via repository directly if exposed.
    // The previous implementation of 'GetPlansUseCase' uses the repository.
    // Let's assume we can add 'getPlans' to repository or we need to add a UseCase.
    // Simplifying: Add getPlansByPatientId to Repository if not present, OR reuse existing if possible.
    // Repository has: getPlans(patientId) -> Future<Either<Failure, List<CarePlanEntity>>>.
    // Wait, the repository interface has getPlans(userId) - wait, check interface.
    // Interface: Future<Either<Failure, List<CarePlanEntity>>> getPlans(String userId, String userType);

    // Use the correct repository method
    final plansResult = await carePlanRepository.getPlansByPatientId(patientId);

    plansResult.fold(
      (failure) {
        debugPrint('Error fetching plans for adherence: ${failure.message}');
      },
      (plans) async {
        patientPlans = plans;
        // 2. Fetch logs for last 7 days
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        final startOf7DaysAgo = DateTime(
          sevenDaysAgo.year,
          sevenDaysAgo.month,
          sevenDaysAgo.day,
        );

        final logsResult = await carePlanRepository
            .getTaskLogsForPatientFromDate(patientId, startOf7DaysAgo);

        logsResult.fold(
          (failure) {
            debugPrint('Error fetching logs for adherence: ${failure.message}');
          },
          (logs) {
            _calculateAdherence(plans, logs);
          },
        );
      },
    );
  }

  void _calculateAdherence(List<CarePlanEntity> plans, List<TaskLog> logs) {
    int totalExpected = 0;
    int totalExecuted = 0;

    adherenceCounts.clear();
    adherenceGoals.clear();

    for (final plan in plans) {
      // Calculate Goal for 7 days
      final freq = plan.frequency;
      int DailyGoal = 1;
      if (freq != null && freq > 0) {
        DailyGoal = (24 / freq).floor();
      }
      final weeklyGoal = DailyGoal * 7;
      adherenceGoals[plan.id] = weeklyGoal;
      totalExpected += weeklyGoal;

      // Count logs
      final planLogs = logs.where((l) {
        final pointer = l.get<ParseObject>('planId');
        return pointer?.objectId == plan.id;
      }).length;
      adherenceCounts[plan.id] = planLogs;
      totalExecuted += planLogs;
    }

    if (totalExpected > 0) {
      overallAdherence = (totalExecuted / totalExpected) * 100;
      if (overallAdherence > 100) overallAdherence = 100;
    } else {
      overallAdherence =
          0.0; // Or 100? If no tasks expected, adherence is N/A or 100. Let's say 0 for now or handled in UI.
      if (plans.isEmpty) overallAdherence = 0; // No plans
    }
  }
}
