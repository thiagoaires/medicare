import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../repositories/check_in_repository.dart';

class HasCheckInTodayUseCase {
  final CheckInRepository repository;

  HasCheckInTodayUseCase(this.repository);

  Future<Either<Failure, bool>> call(String planId) async {
    return await repository.hasCheckInToday(planId);
  }
}
