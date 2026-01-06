import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ProfileEntity profile) {
    return repository.updateProfile(profile);
  }
}
