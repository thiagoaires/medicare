import 'dart:io';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/check_in_model.dart';

abstract class CheckInRemoteDataSource {
  Future<void> create(String planId, String? notes, int? feeling, File? photo);
  Future<List<CheckInModel>> getByPlan(String planId);
}

class ParseCheckInDataSourceImpl implements CheckInRemoteDataSource {
  @override
  Future<void> create(
    String planId,
    String? notes,
    int? feeling,
    File? photo,
  ) async {
    final checkIn = ParseObject('CheckIn');
    checkIn.set('planId', planId);
    checkIn.set('date', DateTime.now());
    checkIn.set<bool>('status', true);

    if (notes != null) {
      checkIn.set('notes', notes);
    }
    if (feeling != null) {
      checkIn.set<int>('feeling', feeling);
    }

    if (photo != null) {
      final parseFile = ParseFile(photo);
      final response = await parseFile.save();
      if (!response.success) {
        throw ServerException(
          message: response.error?.message ?? 'Failed to upload photo',
        );
      }
      checkIn.set('photo', parseFile);
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
