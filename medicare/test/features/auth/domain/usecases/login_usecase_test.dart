import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medicare/features/auth/domain/entities/user_entity.dart';
import 'package:medicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicare/features/auth/domain/usecases/login_usecase.dart';
import 'package:medicare/features/core/errors/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tUserEntity = UserEntity(
    id: '1',
    username: 'Test User',
    email: 'test@example.com',
    userType: 'paciente',
  );

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  test('should get user entity from the repository', () async {
    // Arrange
    when(
      () => mockRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => const Right(tUserEntity));

    // Act
    final result = await useCase(tEmail, tPassword);

    // Assert
    expect(result, const Right(tUserEntity));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.login(tEmail, tPassword),
    ).thenAnswer((_) async => const Left(ServerFailure('Login failed')));

    // Act
    final result = await useCase(tEmail, tPassword);

    // Assert
    expect(result, const Left(ServerFailure('Login failed')));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
