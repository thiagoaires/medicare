import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/care_plan_entity.dart';

class CarePlanModel extends CarePlanEntity {
  const CarePlanModel({
    required super.id,
    required super.title,
    required super.description,
    required super.doctorId,
    required super.patientId,
    required super.startDate,
    super.doctorName,
  });

  factory CarePlanModel.fromParse(ParseObject object) {
    // Handling doctor pointer or id
    String doctorId = '';
    String doctorName = '';
    if (object.get('doctor') != null) {
      // If included, we might get the object, otherwise just the ptr
      var doc = object.get<ParseObject>('doctor');
      if (doc != null) {
        doctorId = doc.objectId ?? '';
        doctorName = () {
          final fullName = doc.get<String>('fullName');
          if (fullName != null && fullName.isNotEmpty) return fullName;
          return doc.get<String>('username') ?? 'Sem Nome';
        }();
      }
    }

    return CarePlanModel(
      id: object.objectId ?? '',
      title: object.get<String>('title') ?? '',
      description: object.get<String>('description') ?? '',
      doctorId: doctorId,
      patientId: object.get<String>('patientId') ?? '',
      startDate: object.get<DateTime>('startDate') ?? DateTime.now(),
      doctorName: doctorName.isNotEmpty ? doctorName : null,
    );
  }

  ParseObject toParse() {
    final parseObject = ParseObject('CarePlan');
    if (id.isNotEmpty) {
      parseObject.objectId = id;
    }
    parseObject.set('title', title);
    parseObject.set('description', description);
    parseObject.set('patientId', patientId);
    parseObject.set('startDate', startDate);
    // Note: 'doctor' pointer is better handled in the DataSource where we have access to context/currentUser
    // or we can expect it to be passed.
    // However, adhering to the prompt "In create... set title, description and create a Pointer for the doctor (current User)",
    // this logic seems to belong to the DataSource.

    return parseObject;
  }
}
