import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/care_plan_model.dart';

abstract class CarePlanRemoteDataSource {
  Future<void> create(CarePlanModel plan);
  Future<List<CarePlanModel>> get({String? patientId, String? doctorId});
}

class ParseCarePlanDataSourceImpl implements CarePlanRemoteDataSource {
  @override
  Future<void> create(CarePlanModel plan) async {
    final user = await ParseUser.currentUser() as ParseUser?;

    if (user == null) {
      throw const ServerException(message: 'User not logged in');
    }

    final parseObject = ParseObject('CarePlan');
    parseObject.set('title', plan.title);
    parseObject.set('description', plan.description);
    parseObject.set('patientId', plan.patientId); // String column
    parseObject.set<DateTime>('startDate', plan.startDate);

    // Pointer to current doctor
    parseObject.set('doctor', user.toPointer());

    final response = await parseObject.save();

    if (!response.success) {
      throw ServerException(
        message: response.error?.message ?? 'Error creating plan',
      );
    }
  }

  @override
  Future<List<CarePlanModel>> get({String? patientId, String? doctorId}) async {
    final query = QueryBuilder<ParseObject>(ParseObject('CarePlan'));

    if (patientId != null) {
      query.whereEqualTo('patientId', patientId); // String comparison
    }

    if (doctorId != null) {
      // Pointer comparison
      final doctorPointer = ParseUser(doctorId, null, null).toPointer();
      query.whereEqualTo('doctor', doctorPointer);
    }

    // Include doctor details if needed, but for now just the plan
    // query.includeObject(['doctor']);

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>)
          .map((e) => CarePlanModel.fromParse(e))
          .toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Error fetching plans',
      );
    }
  }
}
