import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medicare/features/core/errors/exceptions.dart';
import 'package:medicare/features/auth/infra/datasources/auth_remote_datasource.dart';
import 'package:medicare/features/auth/infra/datasources/auth_parse_client.dart';
import 'package:medicare/features/auth/infra/models/user_model.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MockAuthParseClient extends Mock implements AuthParseClient {}

class FakeParseUser extends Fake implements ParseUser {
  @override
  String? get objectId => '1';

  @override
  String? get emailAddress => 'test@example.com';

  @override
  T? get<T>(String key, {T? defaultValue}) {
    if (key == 'fullName') return 'Test User' as T;
    if (key == 'userType') return 'paciente' as T;
    return defaultValue;
  }

  @override
  void set<T>(String key, T value, {bool forceUpdate = true}) {
    // No-op for fake
  }

  @override
  void setACL<ParseACL>(ParseACL acl) {
    // No-op for fake
  }
}

class FakeParseObject extends Fake implements ParseObject {}

class MockParseResponse extends Mock implements ParseResponse {}

void main() {
  late ParseAuthDataSourceImpl dataSource;
  late MockAuthParseClient mockClient;

  setUp(() {
    mockClient = MockAuthParseClient();
    dataSource = ParseAuthDataSourceImpl(client: mockClient);
    registerFallbackValue(FakeParseUser());
    registerFallbackValue(FakeParseObject());
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tType = 'paciente';

  // We use our FakeParseUser to simulate a return from the SDK that we can convert to UserModel
  final tParseUser = FakeParseUser();

  group('login', () {
    test('should return UserModel when login is successful', () async {
      // Arrange
      final response = MockParseResponse();
      when(() => response.success).thenReturn(true);
      when(() => response.result).thenReturn(tParseUser);

      // Ensure tParseUser is not null and has data
      expect(tParseUser, isNotNull);

      when(
        () => mockClient.login(tEmail, tPassword),
      ).thenAnswer((_) async => response);

      // Act
      final result = await dataSource.login(tEmail, tPassword);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      verify(() => mockClient.login(tEmail, tPassword)).called(1);
    });

    test('should throw ServerException when login fails', () async {
      // Arrange
      final response = MockParseResponse();
      when(() => response.success).thenReturn(false);
      when(
        () => response.error,
      ).thenReturn(ParseError(code: 1, message: 'Login failed'));
      when(
        () => mockClient.login(tEmail, tPassword),
      ).thenAnswer((_) async => response);

      // Act
      final call = dataSource.login;

      // Assert
      expect(() => call(tEmail, tPassword), throwsA(isA<ServerException>()));
      verify(() => mockClient.login(tEmail, tPassword)).called(1);
    });
  });

  group('register', () {
    test('should return UserModel when registration is successful', () async {
      // Arrange
      final signUpResponse = MockParseResponse();
      when(() => signUpResponse.success).thenReturn(true);
      when(() => signUpResponse.result).thenReturn(tParseUser);

      final saveResponse = MockParseResponse();
      when(() => saveResponse.success).thenReturn(true);

      when(
        () => mockClient.createUser(any(), any(), any()),
      ).thenReturn(tParseUser);
      when(
        () => mockClient.signUp(any()),
      ).thenAnswer((_) async => signUpResponse);
      when(() => mockClient.save(any())).thenAnswer((_) async => saveResponse);

      // Act
      final result = await dataSource.register(tName, tEmail, tPassword, tType);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      verify(() => mockClient.signUp(any())).called(1);
      verify(() => mockClient.save(any())).called(1);
    });

    test('should throw ServerException when registration fails', () async {
      // Arrange
      final response = MockParseResponse();
      when(() => response.success).thenReturn(false);
      when(
        () => response.error,
      ).thenReturn(ParseError(code: 1, message: 'Register failed'));

      when(
        () => mockClient.createUser(any(), any(), any()),
      ).thenReturn(tParseUser);
      when(() => mockClient.signUp(any())).thenAnswer((_) async => response);

      // Act
      final call = dataSource.register;

      // Assert
      expect(
        () => call(tName, tEmail, tPassword, tType),
        throwsA(isA<ServerException>()),
      );
      verify(() => mockClient.signUp(any())).called(1);
    });
  });

  group('getCurrentUser', () {
    test('should return UserModel when user is logged in', () async {
      // Arrange
      final response = MockParseResponse();
      when(() => response.success).thenReturn(true);
      when(() => response.result).thenReturn(tParseUser);

      // We need a ParseUser with sessionToken not null
      // Since ParseUser is a complex object, we can rely on our Fake or mocking behavior.
      // But for 'sessionToken', it's a property.
      // mocking locally created objects is hard.
      // However The refactored code does:
      // final user = await client.currentUser();
      // if (user != null && user.sessionToken != null) ...

      // We need to return a Mock or Fake that returns a session token.

      final mockUser = MockParseUser();
      when(() => mockUser.sessionToken).thenReturn('token');
      when(() => mockUser.objectId).thenReturn('1');
      when(() => mockUser.emailAddress).thenReturn('test@example.com');
      when(() => mockUser.get<String>('fullName')).thenReturn('Test User');
      when(() => mockUser.get<String>('userType')).thenReturn('paciente');

      when(() => mockClient.currentUser()).thenAnswer((_) async => mockUser);
      when(
        () => mockClient.getUpdatedUser(mockUser),
      ).thenAnswer((_) async => response);

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result, isA<UserModel>());
      verify(() => mockClient.currentUser()).called(1);
      verify(() => mockClient.getUpdatedUser(mockUser)).called(1);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(() => mockClient.currentUser()).thenAnswer((_) async => null);

      // Act
      final result = await dataSource.getCurrentUser();

      // Assert
      expect(result, null);
      verify(() => mockClient.currentUser()).called(1);
    });

    test('should throw ServerException when unexpected error occurs', () async {
      // Arrange
      when(() => mockClient.currentUser()).thenThrow(Exception('Error'));

      // Act
      final call = dataSource.getCurrentUser;

      // Assert
      expect(call, throwsA(isA<ServerException>()));
      verify(() => mockClient.currentUser()).called(1);
    });
  });
}

class MockParseUser extends Mock implements ParseUser {}
