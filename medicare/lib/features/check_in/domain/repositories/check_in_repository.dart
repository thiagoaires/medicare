import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/check_in_entity.dart';

abstract class CheckInRepository {
  Future<Either<Failure, Unit>> createCheckIn(
    String planId,
    String? notes,
    int? feeling,
    File? photo,
  );
  Future<Either<Failure, List<CheckInEntity>>> getCheckInsForPlan(
    String planId,
  );
  Future<Either<Failure, List<CheckInEntity>>> getCheckInsByPatient(
    String patientId,
  );
  Future<Either<Failure, bool>> hasCheckInToday(String planId);
}
