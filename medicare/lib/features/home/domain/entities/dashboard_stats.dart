import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalPlans;
  final int checkInsToday;

  const DashboardStats({required this.totalPlans, required this.checkInsToday});

  @override
  List<Object> get props => [totalPlans, checkInsToday];
}
