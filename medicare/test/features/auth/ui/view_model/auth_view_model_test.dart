import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medicare/features/auth/domain/entities/user_entity.dart';
import 'package:medicare/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicare/features/auth/domain/usecases/login_usecase.dart';
import 'package:medicare/features/auth/domain/usecases/register_usecase.dart';
import 'package:medicare/features/auth/ui/view_model/auth_view_model.dart';
import 'package:medicare/features/core/errors/failures.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthViewModel viewModel;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockAuthRepository = MockAuthRepository();
    viewModel = AuthViewModel(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      authRepository: mockAuthRepository,
    );
  });

  const tUserEntity = UserEntity(
    id: '1',
    username: 'Test User',
    email: 'test@example.com',
    userType: 'paciente',
  );

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tType = 'paciente';

  group('login', () {
    test(
      'should update status to loading then success and set user when login is successful',
      () async {
        // Arrange
        when(
          () => mockLoginUseCase(tEmail, tPassword),
        ).thenAnswer((_) async => const Right(tUserEntity));

        // Act
        final future = viewModel.login(tEmail, tPassword);
        expect(viewModel.status, AuthStatus.loading);
        await future;

        // Assert
        expect(viewModel.status, AuthStatus.success);
        expect(viewModel.user, tUserEntity);
        expect(viewModel.errorMessage, null);
        verify(() => mockLoginUseCase(tEmail, tPassword)).called(1);
      },
    );

    test(
      'should update status to loading then error and set message when login fails',
      () async {
        // Arrange
        when(
          () => mockLoginUseCase(tEmail, tPassword),
        ).thenAnswer((_) async => const Left(ServerFailure('Login failed')));

        // Act
        final future = viewModel.login(tEmail, tPassword);
        expect(viewModel.status, AuthStatus.loading);
        await future;

        // Assert
        expect(viewModel.status, AuthStatus.error);
        expect(viewModel.user, null);
        expect(viewModel.errorMessage, 'Login failed');
        verify(() => mockLoginUseCase(tEmail, tPassword)).called(1);
      },
    );
  });

  group('register', () {
    test(
      'should update status to loading then success and set user when register is successful',
      () async {
        // Arrange
        when(
          () => mockRegisterUseCase(
            name: tName,
            email: tEmail,
            password: tPassword,
            type: tType,
          ),
        ).thenAnswer((_) async => const Right(tUserEntity));

        // Act
        final future = viewModel.register(
          name: tName,
          email: tEmail,
          password: tPassword,
          type: tType,
        );
        expect(viewModel.status, AuthStatus.loading);
        await future;

        // Assert
        expect(viewModel.status, AuthStatus.success);
        expect(viewModel.user, tUserEntity);
        expect(viewModel.errorMessage, null);
        verify(
          () => mockRegisterUseCase(
            name: tName,
            email: tEmail,
            password: tPassword,
            type: tType,
          ),
        ).called(1);
      },
    );

    test(
      'should update status to loading then error and set message when register fails',
      () async {
        // Arrange
        when(
          () => mockRegisterUseCase(
            name: tName,
            email: tEmail,
            password: tPassword,
            type: tType,
          ),
        ).thenAnswer((_) async => const Left(ServerFailure('Register failed')));

        // Act
        final future = viewModel.register(
          name: tName,
          email: tEmail,
          password: tPassword,
          type: tType,
        );
        expect(viewModel.status, AuthStatus.loading);
        await future;

        // Assert
        expect(viewModel.status, AuthStatus.error);
        expect(viewModel.user, null);
        expect(viewModel.errorMessage, 'Register failed');
        verify(
          () => mockRegisterUseCase(
            name: tName,
            email: tEmail,
            password: tPassword,
            type: tType,
          ),
        ).called(1);
      },
    );
  });

  group('checkAuthStatus', () {
    test(
      'should return true, set user and status success when user exists',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Right(tUserEntity));

        // Act
        final future = viewModel.checkAuthStatus();
        expect(viewModel.status, AuthStatus.loading);
        final result = await future;

        // Assert
        expect(result, true);
        expect(viewModel.status, AuthStatus.success);
        expect(viewModel.user, tUserEntity);
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      },
    );

    test(
      'should return false, clear user and status initial when user does not exist (null)',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final future = viewModel.checkAuthStatus();
        expect(viewModel.status, AuthStatus.loading);
        final result = await future;

        // Assert
        expect(result, false);
        expect(viewModel.status, AuthStatus.initial);
        expect(viewModel.user, null);
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      },
    );

    test(
      'should return false, clear user and status initial when repository fails',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(ServerFailure('Error')));

        // Act
        final future = viewModel.checkAuthStatus();
        expect(viewModel.status, AuthStatus.loading);
        final result = await future;

        // Assert
        expect(result, false);
        expect(viewModel.status, AuthStatus.initial);
        expect(viewModel.user, null);
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
      },
    );
  });

  test('resetState should reset status and error message', () {
    // Arrange
    // Set some state first by simulating a failure
    when(
      () => mockLoginUseCase(tEmail, tPassword),
    ).thenAnswer((_) async => const Left(ServerFailure('Login failed')));
    viewModel.login(tEmail, tPassword);

    // Act
    viewModel.resetState();

    // Assert
    expect(viewModel.status, AuthStatus.initial);
    expect(viewModel.errorMessage, null);
  });
}
