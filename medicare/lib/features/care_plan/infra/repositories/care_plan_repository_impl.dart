import 'package:fpdart/fpdart.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/repositories/care_plan_repository.dart';
import '../datasources/care_plan_remote_datasource.dart';
import '../models/care_plan_model.dart';

class CarePlanRepositoryImpl implements CarePlanRepository {
  final CarePlanRemoteDataSource dataSource;

  CarePlanRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, Unit>> createPlan(CarePlanEntity plan) async {
    try {
      final model = CarePlanModel(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        doctorId: plan.doctorId,
        patientId: plan.patientId,
        startDate: plan.startDate,
      );
      await dataSource.create(model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error creating plan'));
    }
  }

  @override
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByDoctorId(
    String doctorId,
  ) async {
    print(
      'DEBUG: [CarePlanRepository] getPlansByDoctorId called for $doctorId',
    );
    try {
      final models = await dataSource.get(doctorId: doctorId);
      print(
        'DEBUG: [CarePlanRepository] getPlansByDoctorId success: ${models.length} found.',
      );
      return Right(models);
    } on ServerException catch (e) {
      print(
        'DEBUG: [CarePlanRepository] getPlansByDoctorId ServerException: ${e.message}',
      );
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print(
        'DEBUG: [CarePlanRepository] getPlansByDoctorId Unexpected Error: $e',
      );
      print('DEBUG: StackTrace: $stackTrace');
      return const Left(ServerFailure('Unexpected error fetching plans'));
    }
  }

  @override
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByPatientId(
    String patientId,
  ) async {
    print(
      'DEBUG: [CarePlanRepository] getPlansByPatientId called for $patientId',
    );
    try {
      final models = await dataSource.get(patientId: patientId);
      print(
        'DEBUG: [CarePlanRepository] getPlansByPatientId success: ${models.length} found.',
      );
      return Right(models);
    } on ServerException catch (e) {
      print('DEBUG: [CarePlanRepository] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      print('DEBUG: [CarePlanRepository] Unexpected Error: $e');
      print('DEBUG: StackTrace: $stackTrace');
      return const Left(ServerFailure('Unexpected error fetching plans'));
    }
  }
}
