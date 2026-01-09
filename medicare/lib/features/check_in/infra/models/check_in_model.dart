import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/check_in_entity.dart';

class CheckInModel extends CheckInEntity {
  const CheckInModel({
    required super.id,
    required super.planId,
    required super.date,
    required super.status,
    super.notes,
    super.feeling,
    super.photoUrl,
    super.photoPath,
  });

  factory CheckInModel.fromParse(ParseObject parseObject) {
    final photoFile = parseObject.get<ParseFile>('photo');
    return CheckInModel(
      id: parseObject.objectId!,
      planId: parseObject.get<String>('planId') ?? '',
      date: parseObject.get<DateTime>('date') ?? DateTime.now(),
      status: parseObject.get<bool>('status') ?? false,
      notes: parseObject.get<String>('notes'),
      feeling: parseObject.get<int>('feeling'),
      photoUrl: photoFile?.url,
    );
  }
}
