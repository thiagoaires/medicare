import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/care_plan_entity.dart';

abstract class CarePlanRepository {
  Future<Either<Failure, Unit>> createPlan(CarePlanEntity plan);
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByPatientId(
    String patientId,
  );
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByDoctorId(
    String doctorId,
  );
}
