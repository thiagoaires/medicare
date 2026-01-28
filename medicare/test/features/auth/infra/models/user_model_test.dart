import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/features/auth/domain/entities/user_entity.dart';
import 'package:medicare/features/auth/infra/models/user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class MockParseUser extends Mock implements ParseUser {}

void main() {
  const tUserModel = UserModel(
    id: '1',
    username: 'Test User',
    email: 'test@example.com',
    userType: 'paciente',
  );

  test('should be a subclass of UserEntity', () async {
    expect(tUserModel, isA<UserEntity>());
  });

  group('fromParse', () {
    test('should return a valid model from JSON', () async {
      // Arrange
      final mockParseUser = MockParseUser();
      when(() => mockParseUser.objectId).thenReturn('1');
      when(() => mockParseUser.get<String>('fullName')).thenReturn('Test User');
      when(() => mockParseUser.emailAddress).thenReturn('test@example.com');
      when(() => mockParseUser.get<String>('userType')).thenReturn('paciente');

      // Act
      final result = UserModel.fromParse(mockParseUser);

      // Assert
      expect(result, tUserModel);
    });

    test('should return default values when fields are missing', () async {
      // Arrange
      final mockParseUser = MockParseUser();
      when(() => mockParseUser.objectId).thenReturn('1');
      when(() => mockParseUser.get<String>('fullName')).thenReturn(null);
      when(() => mockParseUser.emailAddress).thenReturn(null);
      when(() => mockParseUser.get<String>('userType')).thenReturn(null);
      // The implementation uses ?? 'Sem Nome', ?? '', ?? 'paciente'

      // Act
      final result = UserModel.fromParse(mockParseUser);

      // Assert
      expect(result.username, 'Sem Nome');
      expect(result.email, '');
      expect(result.userType, 'paciente');
    });
  });
}
