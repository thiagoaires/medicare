import 'package:equatable/equatable.dart';

class CarePlanEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String doctorId;
  final String patientId;
  final DateTime startDate;

  const CarePlanEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.doctorId,
    required this.patientId,
    required this.startDate,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    doctorId,
    patientId,
    startDate,
  ];
}
