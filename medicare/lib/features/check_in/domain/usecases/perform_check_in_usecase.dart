import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/check_in_entity.dart';
import '../repositories/check_in_repository.dart';

class PerformCheckInUseCase {
  final CheckInRepository repository;

  PerformCheckInUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String planId, String? notes) async {
    // Validação de Negócio: Verificar se já existe check-in HOJE
    final historyResult = await repository.getCheckInsForPlan(planId);

    return historyResult.fold((failure) => Left(failure), (history) async {
      final today = DateTime.now();
      final hasCheckInToday = history.any((checkIn) {
        return checkIn.date.year == today.year &&
            checkIn.date.month == today.month &&
            checkIn.date.day == today.day;
      });

      if (hasCheckInToday) {
        // Já fez check-in hoje
        return const Right(unit);
      }

      return await repository.createCheckIn(planId, notes);
    });
  }
}
