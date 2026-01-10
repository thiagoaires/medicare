import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/care_plan_entity.dart';
import '../../infra/models/task_log.dart';

abstract class CarePlanRepository {
  Future<Either<Failure, Unit>> createPlan(CarePlanEntity plan);
  Future<Either<Failure, Unit>> updatePlan(CarePlanEntity plan);
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByPatientId(
    String patientId,
  );
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByDoctorId(
    String doctorId,
  );
  Future<Either<Failure, Unit>> registerExecution(CarePlanEntity plan);
  Future<Either<Failure, int>> getTodaysTaskCount(String planId);
  Future<Either<Failure, List<TaskLog>>> getTaskLogsForPatientFromDate(
    String patientId,
    DateTime fromDate,
  );
}
