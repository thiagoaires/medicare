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
    final plansResult = await carePlanRepository.getPlansByPatientId(patientId);

    plansResult.fold(
      (failure) {
        debugPrint('Error fetching plans for adherence: ${failure.message}');
      },
      (plans) async {
        patientPlans = plans;

        // Fetch logs for all history (since 2000) to calculate accumulated adherence
        final startOfTime = DateTime(2000);

        final logsResult = await carePlanRepository
            .getTaskLogsForPatientFromDate(patientId, startOfTime);

        logsResult.fold(
          (failure) {
            debugPrint('Error fetching logs for adherence: ${failure.message}');
          },
          (logs) {
            _calculateAdherence(plans, logs);
            notifyListeners(); // Notify to update UI with new calculations
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

    final now = DateTime.now();

    for (final plan in plans) {
      // 1. Calculate Expected Doses (Accumulated)
      final startDate = plan.startDate; // Assuming startDate is reliable

      // Determine cutoff date: Min(now, plan.endDate)
      // If plan has ended, we calculate expected doses only up to that end date.
      DateTime cutoffDate = now;
      if (plan.endDate != null && plan.endDate!.isBefore(now)) {
        cutoffDate = plan.endDate!;
      }

      // Calculate days elapsed (inclusive of start and end dates)
      // We use +1 to count the first day as a full day of treatment opportunity
      int daysElapsed = cutoffDate.difference(startDate).inDays + 1;
      if (daysElapsed < 1) daysElapsed = 1;

      // Heuristic for Frequency (Interval in Hours)
      // UX Fix: Users often confuse "1x per day" with "Frequency = 1" (which means every 1 hour)
      // We apply a "Sanity Check" to fix these common mistakes.
      int hoursInterval = plan.frequency ?? 24; // Default to 24h (1x day)

      if (hoursInterval == 1) {
        hoursInterval = 24; // User likely meant 1x per day
      } else if (hoursInterval == 2) {
        hoursInterval = 12; // User likely meant 2x per day
      } else if (hoursInterval <= 0) {
        hoursInterval = 24; // Fallback for bad data
      }

      // Calculate Daily Frequency (Doses per day)
      int dailyFrequency = (24 / hoursInterval).floor();
      if (dailyFrequency < 1) dailyFrequency = 1;

      // Total expected since start
      final planExpected = daysElapsed * dailyFrequency;
      adherenceGoals[plan.id] = planExpected;
      totalExpected += planExpected;

      // 2. Count Realized Doses (Total logs for this plan)
      final planLogs = logs.where((l) {
        final pointer = l.get<ParseObject>('planId');
        // print('CoreLOG: Log ${l.objectId} points to ${pointer?.objectId}');
        return pointer?.objectId == plan.id;
      }).length;

      adherenceCounts[plan.id] = planLogs;
      totalExecuted += planLogs;
    }

    // Overall Adherence (Average of percentages or Total/Total?)
    // Request implies individual tracking, but card also needs overall.
    // Let's keep overall as TotalRealized / TotalExpected for simplicity validation
    if (totalExpected > 0) {
      overallAdherence = (totalExecuted / totalExpected) * 100;
      if (overallAdherence > 100) overallAdherence = 100;
    } else {
      overallAdherence = 0.0;
    }
  }
}
