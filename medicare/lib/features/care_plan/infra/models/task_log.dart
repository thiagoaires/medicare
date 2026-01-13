import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../../domain/entities/task_log_entity.dart';

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

    final acl = ParseACL();
    acl.setPublicReadAccess(allowed: true);
    acl.setPublicWriteAccess(allowed: false);
    log.setACL(acl);

    return log;
  }

  TaskLogEntity toEntity() {
    return TaskLogEntity(
      id: objectId!,
      executedAt: get<DateTime>(keyExecutedAt)!,
      planId: get<ParseObject>(keyPlanId)?.objectId ?? '',
    );
  }
}
