import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/care_plan_entity.dart';
import '../repositories/care_plan_repository.dart';

class UpdateCarePlanUseCase {
  final CarePlanRepository repository;

  UpdateCarePlanUseCase(this.repository);

  Future<Either<Failure, Unit>> call(CarePlanEntity plan) {
    return repository.updatePlan(plan);
  }
}
