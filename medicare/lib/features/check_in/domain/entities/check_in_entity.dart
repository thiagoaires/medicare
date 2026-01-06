import 'package:equatable/equatable.dart';

class CheckInEntity extends Equatable {
  final String id;
  final String planId;
  final DateTime date;
  final String status;
  final String? notes;

  const CheckInEntity({
    required this.id,
    required this.planId,
    required this.date,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [id, planId, date, status, notes];
}
