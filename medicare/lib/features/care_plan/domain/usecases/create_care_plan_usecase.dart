import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/care_plan_entity.dart';
import '../repositories/care_plan_repository.dart';

class CreateCarePlanUseCase {
  final CarePlanRepository repository;

  CreateCarePlanUseCase(this.repository);

  Future<Either<Failure, Unit>> call(CarePlanEntity plan) async {
    if (plan.title.isEmpty) {
      return const Left(InvalidDataFailure('Title cannot be empty'));
    }
    return repository.createPlan(plan);
  }
}
