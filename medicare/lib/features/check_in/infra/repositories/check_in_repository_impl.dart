import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../../care_plan/domain/repositories/care_plan_repository.dart';
import '../datasources/check_in_remote_datasource.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;
  final CarePlanRepository carePlanRepository;

  CheckInRepositoryImpl(
    this.remoteDataSource, {
    required this.carePlanRepository,
  });

  @override
  Future<Either<Failure, Unit>> createCheckIn(
    String planId,
    String? notes,
    int? feeling,
    File? photo,
  ) async {
    try {
      await remoteDataSource.create(planId, notes, feeling, photo);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CheckInEntity>>> getCheckInsForPlan(
    String planId,
  ) async {
    try {
      final models = await remoteDataSource.getByPlan(planId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CheckInEntity>>> getCheckInsByPatient(
    String patientId,
  ) async {
    try {
      // 1. Fetch plans for the patient
      final plansResult = await carePlanRepository.getPlansByPatientId(
        patientId,
      );

      return plansResult.fold((failure) => Left(failure), (plans) async {
        if (plans.isEmpty) {
          return const Right([]);
        }
        final planIds = plans.map((e) => e.id).toList();

        // 2. Fetch check-ins for these plans
        final models = await remoteDataSource.getByPlanIds(planIds);
        return Right(models);
      });
    } on ServerException catch (e) {
      return Left(ServerFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCheckInToday(String planId) async {
    try {
      final result = await remoteDataSource.hasCheckInToday(planId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro desconhecido: $e'));
    }
  }
}
