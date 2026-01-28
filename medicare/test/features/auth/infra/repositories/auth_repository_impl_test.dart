import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:medicare/features/core/errors/exceptions.dart';
import 'package:medicare/features/core/errors/failures.dart';
import 'package:medicare/features/auth/infra/datasources/auth_remote_datasource.dart';
import 'package:medicare/features/auth/infra/models/user_model.dart';
import 'package:medicare/features/auth/infra/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
  });

  const tUserModel = UserModel(
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
      'should return UserEntity when remote data source is successful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(tEmail, tPassword),
        ).thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, const Right(tUserModel));
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(tEmail, tPassword),
        ).thenThrow(ServerException(message: 'Login failed'));

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, const Left(ServerFailure('Login failed')));
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ServerFailure when remote data source throws generic exception',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(tEmail, tPassword),
        ).thenThrow(Exception('Generic error'));

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        result.fold(
          (failure) => expect(failure.message, contains('Generic error')),
          (_) => fail('Should have returned a Failure'),
        );
      },
    );
  });

  group('register', () {
    test(
      'should return UserEntity when remote data source is successful',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.register(
          tName,
          tEmail,
          tPassword,
          tType,
        );

        // Assert
        expect(result, const Right(tUserModel));
        verify(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).thenThrow(ServerException(message: 'Register failed'));

        // Act
        final result = await repository.register(
          tName,
          tEmail,
          tPassword,
          tType,
        );

        // Assert
        expect(result, const Left(ServerFailure('Register failed')));
        verify(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ServerFailure when remote data source throws generic exception',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).thenThrow(Exception('Generic error'));

        // Act
        final result = await repository.register(
          tName,
          tEmail,
          tPassword,
          tType,
        );

        // Assert
        verify(
          () => mockRemoteDataSource.register(tName, tEmail, tPassword, tType),
        ).called(1);
        result.fold(
          (failure) => expect(failure.message, contains('Generic error')),
          (_) => fail('Should have returned a Failure'),
        );
      },
    );
  });

  group('getCurrentUser', () {
    test(
      'should return UserEntity when remote data source returns user',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, const Right(tUserModel));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test('should return null when remote data source returns null', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenThrow(ServerException(message: 'Error fetching user'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, const Left(ServerFailure('Error fetching user')));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      'should return ServerFailure when remote data source throws generic exception',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenThrow(Exception('Generic error'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        result.fold(
          (failure) => expect(failure.message, contains('Generic error')),
          (_) => fail('Should have returned a Failure'),
        );
      },
    );
  });
}
