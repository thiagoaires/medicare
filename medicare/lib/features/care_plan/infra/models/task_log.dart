import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/care_plan_entity.dart';

class TaskLog extends ParseObject implements ParseCloneable {
  TaskLog() : super('TaskLog');

  TaskLog.clone() : this();

  @override
  TaskLog clone(Map<String, dynamic> map) => TaskLog.clone()..fromJson(map);

  static const String keyPlanId = 'planId';
  static const String keyExecutedAt = 'executedAt';

  factory TaskLog.createForPlan(CarePlanEntity plan) {
    final log = TaskLog();
    log.set(keyPlanId, ParseObject('CarePlan')..objectId = plan.id);
    log.set(keyExecutedAt, DateTime.now());
    return log;
  }
}
