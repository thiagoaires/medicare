import 'package:equatable/equatable.dart';

class TaskLogEntity extends Equatable {
  final String id;
  final DateTime executedAt;
  final String planId;

  const TaskLogEntity({
    required this.id,
    required this.executedAt,
    required this.planId,
  });

  @override
  List<Object?> get props => [id, executedAt, planId];
}
