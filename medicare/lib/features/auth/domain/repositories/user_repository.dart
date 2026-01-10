import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> searchPatients(String term);
}
