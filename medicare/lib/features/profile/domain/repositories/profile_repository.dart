import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, Unit>> updateProfile(ProfileEntity profile);
  Future<Either<Failure, Unit>> logout();
}
