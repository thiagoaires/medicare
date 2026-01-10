import 'package:fpdart/fpdart.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';
import '../../../core/errors/failures.dart';

class SearchPatientsUseCase {
  final UserRepository repository;

  SearchPatientsUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call(String term) async {
    return await repository.searchPatients(term);
  }
}
