import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/check_in_entity.dart';

class CheckInModel extends CheckInEntity {
  const CheckInModel({
    required super.id,
    required super.planId,
    required super.date,
    required super.status,
    super.notes,
  });

  factory CheckInModel.fromParse(ParseObject parseObject) {
    return CheckInModel(
      id: parseObject.objectId!,
      planId: parseObject.get<String>('planId') ?? '',
      date: parseObject.get<DateTime>('date') ?? DateTime.now(),
      status: parseObject.get<bool>('status') ?? false,
      notes: parseObject.get<String>('notes'),
    );
  }
}
