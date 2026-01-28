import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medicare/features/auth/domain/entities/user_entity.dart';
import 'package:medicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicare/features/auth/domain/usecases/register_usecase.dart';
import 'package:medicare/features/core/errors/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const tUserEntity = UserEntity(
    id: '1',
    username: 'Test User',
    email: 'test@example.com',
    userType: 'paciente',
  );

  const tName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tType = 'paciente';

  test(
    'should get user entity from the repository upon registration',
    () async {
      // Arrange
      when(
        () => mockRepository.register(tName, tEmail, tPassword, tType),
      ).thenAnswer((_) async => const Right(tUserEntity));

      // Act
      final result = await useCase(
        name: tName,
        email: tEmail,
        password: tPassword,
        type: tType,
      );

      // Assert
      expect(result, const Right(tUserEntity));
      verify(
        () => mockRepository.register(tName, tEmail, tPassword, tType),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return failure when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.register(tName, tEmail, tPassword, tType),
    ).thenAnswer((_) async => const Left(ServerFailure('Register failed')));

    // Act
    final result = await useCase(
      name: tName,
      email: tEmail,
      password: tPassword,
      type: tType,
    );

    // Assert
    expect(result, const Left(ServerFailure('Register failed')));
    verify(
      () => mockRepository.register(tName, tEmail, tPassword, tType),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
