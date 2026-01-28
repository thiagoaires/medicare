import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/features/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should support value equality', () {
      const failure1 = ServerFailure('error');
      const failure2 = ServerFailure('error');
      expect(failure1, equals(failure2));
      expect(failure1.props, ['error']);
    });
  });

  group('CacheFailure', () {
    test('should support value equality', () {
      const failure1 = CacheFailure('error');
      const failure2 = CacheFailure('error');
      expect(failure1, equals(failure2));
      expect(failure1.props, ['error']);
    });
  });

  group('InvalidDataFailure', () {
    test('should support value equality', () {
      const failure1 = InvalidDataFailure('error');
      const failure2 = InvalidDataFailure('error');
      expect(failure1, equals(failure2));
      expect(failure1.props, ['error']);
    });
  });
}
