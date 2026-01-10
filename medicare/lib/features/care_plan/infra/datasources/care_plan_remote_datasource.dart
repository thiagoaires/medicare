import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/care_plan_model.dart';
import '../models/task_log.dart';

abstract class CarePlanRemoteDataSource {
  Future<void> create(CarePlanModel plan);
  Future<List<CarePlanModel>> get({String? patientId, String? doctorId});
  Future<void> update(CarePlanModel plan);
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids);
  Future<void> registerExecution(CarePlanModel plan);
  Future<List<TaskLog>> getTodaysTaskLogs(String planId);
  Future<List<TaskLog>> getTaskLogsForPatientFromDate(
    String patientId,
    DateTime fromDate,
  );
}

class ParseCarePlanDataSourceImpl implements CarePlanRemoteDataSource {
  @override
  Future<void> registerExecution(CarePlanModel plan) async {
    final taskLog = TaskLog.createForPlan(plan);
    final response = await taskLog.save();

    if (!response.success) {
      throw ServerException(
        message: response.error?.message ?? 'Error registering execution',
      );
    }
  }

  @override
  Future<List<TaskLog>> getTodaysTaskLogs(String planId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final query = QueryBuilder<TaskLog>(TaskLog())
      ..whereEqualTo('planId', ParseObject('CarePlan')..objectId = planId)
      ..whereGreaterThanOrEqualsTo('executedAt', startOfDay);

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>)
          .map((e) => e as TaskLog)
          .toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Error fetching task logs',
      );
    }
  }

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
    QueryBuilder<ParseObject> query;

    if (patientId != null) {
      // Query 1: Check String column 'patientId'
      final qString = QueryBuilder<ParseObject>(ParseObject('CarePlan'))
        ..whereEqualTo('patientId', patientId);

      // Query 2: Check Pointer column 'patient'
      final patientPointer = ParseUser(null, null, null)..objectId = patientId;
      final qPointer = QueryBuilder<ParseObject>(ParseObject('CarePlan'))
        ..whereEqualTo('patient', patientPointer.toPointer());

      // Combine queries
      query = QueryBuilder.or(ParseObject('CarePlan'), [qString, qPointer]);
    } else {
      query = QueryBuilder<ParseObject>(ParseObject('CarePlan'));
    }

    if (doctorId != null) {
      // Pointer comparison
      final doctorPointer = ParseUser(null, null, null)..objectId = doctorId;
      query.whereEqualTo('doctor', doctorPointer.toPointer());
    }

    // Include doctor details if needed
    query.includeObject([
      'doctor',
      'patient',
    ]); // Include patient too just in case

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
    // Sub-query for Object IDs
    final qId = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereContainedIn('objectId', ids);

    // Sub-query for Usernames (often emails in this app)
    final qUsername = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereContainedIn('username', ids);

    // Sub-query for Emails
    final qEmail = QueryBuilder<ParseUser>(ParseUser.forQuery())
      ..whereContainedIn('email', ids);

    // Combine queries
    final query = QueryBuilder.or(ParseUser.forQuery(), [
      qId,
      qUsername,
      qEmail,
    ]);

    query.setLimit(1000);

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>).map((e) {
        return {
          'id': e.objectId, // Return actual ObjectId
          'lookupKey': e.objectId,
          // WAIT: If I search by 'email', the Repo expects the key `patientId` (which is the email) to match.
          // The Repo maps namesMap[models.patientId].
          // If model.patientId is 'john@email.com', but result.objectId is 'XyZ', result map will have key 'XyZ'.
          // Repo lookup: namesMap['john@email.com'] -> Null.

          // I need to return the 'matched' key. But I don't know which one matched easiest.
          // Better approach: In Repository, if the ID doesn't match, search by details?
          // No, datasource should return enough info.

          // If I return the object, I can match it back in Repository?
          // Or I check if 'username' IS in the `ids` list.
          'name': () {
            final fullName = e.get<String>('fullName');

            if (fullName != null && fullName.isNotEmpty) return fullName;

            final username = e.get<String>('username');
            if (username != null && username.isNotEmpty) return username;

            final email = e.get<String>('email');
            if (email != null && email.contains('@')) {
              return email.split('@')[0];
            }

            return 'Usuário Sem Nome';
          }(),
          'email': e.get<String>('email'),
          'username': e.get<String>('username'),
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

  @override
  Future<List<TaskLog>> getTaskLogsForPatientFromDate(
    String patientId,
    DateTime fromDate,
  ) async {
    // 1. Fetch plans for patient to get their IDs
    final plans = await get(patientId: patientId);

    if (plans.isEmpty) return [];

    final planPointers = plans
        .map((p) => (ParseObject('CarePlan')..objectId = p.id).toPointer())
        .toList();

    // 2. Query TaskLog where planId IN planPointers AND executedAt >= fromDate
    final query = QueryBuilder<TaskLog>(TaskLog())
      ..whereContainedIn('planId', planPointers)
      ..whereGreaterThanOrEqualsTo('executedAt', fromDate)
      ..includeObject(['planId']);

    // Limit to large number just in case
    query.setLimit(1000);

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>)
          .map((e) => e as TaskLog)
          .toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Error fetching task logs',
      );
    }
  }
}
