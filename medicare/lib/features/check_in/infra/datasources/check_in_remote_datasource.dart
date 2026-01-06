import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/check_in_model.dart';

abstract class CheckInRemoteDataSource {
  Future<void> create(String planId, String? notes);
  Future<List<CheckInModel>> getByPlan(String planId);
}

class ParseCheckInDataSourceImpl implements CheckInRemoteDataSource {
  @override
  Future<void> create(String planId, String? notes) async {
    final checkIn = ParseObject('CheckIn');
    checkIn.set('planId', planId);
    checkIn.set('date', DateTime.now());
    checkIn.set('status', 'concluido');
    if (notes != null) {
      checkIn.set('notes', notes);
    }

    final response = await checkIn.save();

    if (!response.success) {
      throw ServerException(
        message: response.error?.message ?? 'Failed to create check-in',
      );
    }
  }

  @override
  Future<List<CheckInModel>> getByPlan(String planId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('CheckIn'));
    query.whereEqualTo('planId', planId);
    query.orderByDescending('date');

    final response = await query.query();

    if (response.success && response.results != null) {
      return (response.results as List<ParseObject>)
          .map((e) => CheckInModel.fromParse(e))
          .toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Failed to fetch check-ins',
      );
    }
  }
}
