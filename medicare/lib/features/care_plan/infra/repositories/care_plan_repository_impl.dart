import 'package:fpdart/fpdart.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/repositories/care_plan_repository.dart';
import '../datasources/care_plan_remote_datasource.dart';
import '../models/care_plan_model.dart';
import '../models/task_log.dart';

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
        endDate: plan.endDate,
        frequency: plan.frequency,
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
  Future<Either<Failure, Unit>> updatePlan(CarePlanEntity plan) async {
    try {
      final model = CarePlanModel(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        doctorId: plan.doctorId,
        patientId: plan.patientId,
        startDate: plan.startDate,
        endDate: plan.endDate,
        frequency: plan.frequency,
      );
      await dataSource.update(model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error updating plan'));
    }
  }

  @override
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByDoctorId(
    String doctorId,
  ) async {
    try {
      final models = await dataSource.get(doctorId: doctorId);

      // Smart Fetching: Get Patient Names
      final patientIds = models.map((e) => e.patientId.trim()).toSet().toList();

      final usersData = await dataSource.getUsersByIds(patientIds);

      final namesMap = {
        for (var user in usersData)
          (user['id'] as String).trim(): user['name'] as String,
      };

      final entities = models.map((model) {
        return CarePlanEntity(
          id: model.id,
          title: model.title,
          description: model.description,
          doctorId: model.doctorId,
          patientId: model.patientId,
          startDate: model.startDate,
          endDate: model.endDate,
          frequency: model.frequency,
          patientName: namesMap[model.patientId.trim()], // Populate name
        );
      }).toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching plans'));
    }
  }

  @override
  Future<Either<Failure, List<CarePlanEntity>>> getPlansByPatientId(
    String patientId,
  ) async {
    try {
      final models = await dataSource.get(patientId: patientId);

      // Smart Fetching: Get Doctor Names
      final doctorIds = models.map((e) => e.doctorId.trim()).toSet().toList();

      final usersData = await dataSource.getUsersByIds(doctorIds);

      final namesMap = {
        for (var user in usersData)
          (user['id'] as String).trim(): user['name'] as String,
      };

      final entities = models.map((model) {
        return CarePlanEntity(
          id: model.id,
          title: model.title,
          description: model.description,
          doctorId: model.doctorId,
          patientId: model.patientId,
          startDate: model.startDate,
          endDate: model.endDate,
          frequency: model.frequency,
          doctorName: namesMap[model.doctorId.trim()], // Populate name
        );
      }).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> registerExecution(CarePlanEntity plan) async {
    try {
      final model = CarePlanModel(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        doctorId: plan.doctorId,
        patientId: plan.patientId,
        startDate: plan.startDate,
        endDate: plan.endDate,
        frequency: plan.frequency,
      );
      await dataSource.registerExecution(model);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(
        ServerFailure('Unexpected error registering execution'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getTodaysTaskCount(String planId) async {
    try {
      final logs = await dataSource.getTodaysTaskLogs(planId);
      return Right(logs.length);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching task count'));
    }
  }

  @override
  Future<Either<Failure, List<TaskLog>>> getTaskLogsForPatientFromDate(
    String patientId,
    DateTime fromDate,
  ) async {
    try {
      final logs = await dataSource.getTaskLogsForPatientFromDate(
        patientId,
        fromDate,
      );
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error fetching task logs'));
    }
  }
}
