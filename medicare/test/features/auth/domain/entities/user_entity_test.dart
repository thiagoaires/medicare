import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/features/auth/domain/entities/user_entity.dart';

void main() {
  const tUserEntity = UserEntity(
    id: '1',
    username: 'Test User',
    email: 'test@example.com',
    userType: 'paciente',
  );

  test('props should contain all properties', () {
    expect(tUserEntity.props, [
      '1',
      'Test User',
      'test@example.com',
      'paciente',
    ]);
  });
}
