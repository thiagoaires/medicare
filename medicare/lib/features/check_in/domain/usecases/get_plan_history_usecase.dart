import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/check_in_entity.dart';
import '../repositories/check_in_repository.dart';

class GetPlanHistoryUseCase {
  final CheckInRepository repository;

  GetPlanHistoryUseCase(this.repository);

  Future<Either<Failure, List<CheckInEntity>>> call(String planId) async {
    return await repository.getCheckInsForPlan(planId);
  }
}
