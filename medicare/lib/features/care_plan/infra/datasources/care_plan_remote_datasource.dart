import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/care_plan_model.dart';

abstract class CarePlanRemoteDataSource {
  Future<void> create(CarePlanModel plan);
  Future<List<CarePlanModel>> get({String? patientId, String? doctorId});
  Future<void> update(CarePlanModel plan);
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids);
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

    // Define ACLs
    final acl = ParseACL(owner: user);
    acl.setPublicReadAccess(
      allowed: true,
    ); // Allow patients to find it (simplify for now, or use setReadAccess(userId))
    // acl.setReadAccess(userId: plan.patientId, allowed: true); // Better, but requires patientId to be exactly valid ObjectId of a User.
    // Given patientId is just a string in our entity/model, let's assume it IS the ObjectId.
    // However, if the user types a random string, this might fail or do nothing.
    // For safety, let's allow Public Read for now, or try setting if it looks like an ID.
    if (plan.patientId.isNotEmpty) {
      acl.setReadAccess(userId: plan.patientId, allowed: true);
    }
    acl.setWriteAccess(
      userId: user.objectId!,
      allowed: true,
    ); // Redundant if owner is set, but explicit.

    parseObject.setACL(acl);

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
      final doctorPointer = ParseUser(null, null, null)..objectId = doctorId;
      query.whereEqualTo('doctor', doctorPointer.toPointer());
    }

    // Include doctor details if needed, but for now just the plan
    // query.includeObject(['doctor']);

    final response = await query.query();

    if (response.success && response.results != null) {
      try {
        return (response.results as List<ParseObject>)
            .map((e) => CarePlanModel.fromParse(e))
            .toList();
      } catch (e) {
        throw ServerException(message: 'Error mapping data: $e');
      }
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Error fetching plans',
      );
    }
  }

  @override
  Future<void> update(CarePlanModel plan) async {
    final parseObject = ParseObject('CarePlan')..objectId = plan.id;

    parseObject.set('title', plan.title);
    parseObject.set('description', plan.description);
    parseObject.set<DateTime>('startDate', plan.startDate);
    // Note: patientId and doctor usually don't change in update, or locked by logic.

    final response = await parseObject.save();

    if (!response.success) {
      throw ServerException(
        message: response.error?.message ?? 'Error updating plan',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids) async {
    final query = QueryBuilder<ParseUser>(ParseUser.forQuery());
    query.whereContainedIn('objectId', ids);
    // Limit to likely max? 1000 default is Parse limit.
    query.setLimit(1000);

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>).map((e) {
        return {
          'id': e.objectId,
          'name': e.get<String>('fullName') ?? e.get<String>('username') ?? '',
        };
      }).toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Error fetching users',
      );
    }
  }
}
