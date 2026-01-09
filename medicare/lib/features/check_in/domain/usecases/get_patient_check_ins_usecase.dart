import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/check_in_entity.dart';
import '../repositories/check_in_repository.dart';

class GetPatientCheckInsUseCase {
  final CheckInRepository repository;

  GetPatientCheckInsUseCase(this.repository);

  Future<Either<Failure, List<CheckInEntity>>> call(String patientId) async {
    return await repository.getCheckInsByPatient(patientId);
  }
}
