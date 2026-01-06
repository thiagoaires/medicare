import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/check_in_entity.dart';

abstract class CheckInRepository {
  Future<Either<Failure, Unit>> createCheckIn(String planId, String? notes);
  Future<Either<Failure, List<CheckInEntity>>> getCheckInsForPlan(
    String planId,
  );
}
