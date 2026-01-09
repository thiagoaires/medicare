import 'package:equatable/equatable.dart';

class CheckInEntity extends Equatable {
  final String id;
  final String planId;
  final DateTime date;
  final bool status;
  final String? notes;
  final int? feeling;
  final String? photoUrl;
  final String? photoPath;

  const CheckInEntity({
    required this.id,
    required this.planId,
    required this.date,
    required this.status,
    this.notes,
    this.feeling,
    this.photoUrl,
    this.photoPath,
  });

  @override
  List<Object?> get props => [id, planId, date, status, notes];
}
