import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../../care_plan/domain/repositories/care_plan_repository.dart';
import '../../../check_in/domain/repositories/check_in_repository.dart';
import '../entities/dashboard_stats.dart';

class GetDoctorStatsUseCase {
  final CarePlanRepository carePlanRepository;
  final CheckInRepository checkInRepository;

  GetDoctorStatsUseCase({
    required this.carePlanRepository,
    required this.checkInRepository,
  });

  Future<Either<Failure, DashboardStats>> call(String doctorId) async {
    // 1. Buscar planos do médico
    final plansResult = await carePlanRepository.getPlansByDoctorId(doctorId);

    return plansResult.fold((failure) => Left(failure), (plans) async {
      int totalPlans = plans.length;
      int checkInsToday = 0;
      final today = DateTime.now();

      // 2. Verificar check-ins para cada plano
      for (final plan in plans) {
        final historyResult = await checkInRepository.getCheckInsForPlan(
          plan.id,
        );

        final hasCheckIn = historyResult.fold(
          (_) => false, // Se der erro ao buscar histórico, assume sem check-in
          (history) => history.any((checkIn) {
            // Comparação de data ignorando horário (mesma lógica do CheckInViewModel)
            final localDate = checkIn.date.toLocal();
            final localToday = today.toLocal();
            return localDate.year == localToday.year &&
                localDate.month == localToday.month &&
                localDate.day == localToday.day;
          }),
        );

        if (hasCheckIn) {
          checkInsToday++;
        }
      }

      return Right(
        DashboardStats(totalPlans: totalPlans, checkInsToday: checkInsToday),
      );
    });
  }
}
