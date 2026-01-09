import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../datasources/check_in_remote_datasource.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDataSource remoteDataSource;

  CheckInRepositoryImpl(this.remoteDataSource);

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
}
