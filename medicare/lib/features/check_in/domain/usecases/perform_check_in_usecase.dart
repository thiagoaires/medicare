import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../repositories/check_in_repository.dart';

class PerformCheckInUseCase {
  final CheckInRepository repository;

  PerformCheckInUseCase(this.repository);

  Future<Either<Failure, Unit>> call(
    String planId,
    String? notes, {
    int? feeling,
    File? photo,
  }) async {
    // Validação de Negócio: Verificar se já existe check-in HOJE
    final historyResult = await repository.getCheckInsForPlan(planId);

    return historyResult.fold((failure) => Left(failure), (history) async {
      final today = DateTime.now();

      bool isSameDay(DateTime a, DateTime b) {
        final localA = a.toLocal();
        final localB = b.toLocal();
        return localA.year == localB.year &&
            localA.month == localB.month &&
            localA.day == localB.day;
      }

      final hasCheckInToday = history.any((checkIn) {
        return isSameDay(checkIn.date, today);
      });

      if (hasCheckInToday) {
        // Já fez check-in hoje
        return const Right(unit);
      }

      return await repository.createCheckIn(planId, notes, feeling, photo);
    });
  }
}
