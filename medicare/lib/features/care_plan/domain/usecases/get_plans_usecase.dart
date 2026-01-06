import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/care_plan_entity.dart';
import '../repositories/care_plan_repository.dart';

class GetPlansUseCase {
  final CarePlanRepository repository;

  GetPlansUseCase(this.repository);

  Future<Either<Failure, List<CarePlanEntity>>> byPatientId(String patientId) {
    return repository.getPlansByPatientId(patientId);
  }

  Future<Either<Failure, List<CarePlanEntity>>> byDoctorId(String doctorId) {
    return repository.getPlansByDoctorId(doctorId);
  }
}
