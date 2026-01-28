import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/features/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should be support value equality', () {
      const exception1 = ServerException(message: 'error');
      const exception2 = ServerException(message: 'error');
      expect(exception1, equals(exception2));
      expect(exception1.props, ['error']);
    });
  });

  group('CacheException', () {
    test('should be support value equality', () {
      const exception1 = CacheException(message: 'error');
      const exception2 = CacheException(message: 'error');
      expect(exception1, equals(exception2));
      expect(exception1.props, ['error']);
    });
  });
}
