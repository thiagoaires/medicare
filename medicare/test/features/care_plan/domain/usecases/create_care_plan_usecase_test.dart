import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medicare/features/care_plan/domain/entities/care_plan_entity.dart';
import 'package:medicare/features/care_plan/domain/repositories/care_plan_repository.dart';
import 'package:medicare/features/care_plan/domain/usecases/create_care_plan_usecase.dart';
import 'package:medicare/features/core/errors/failures.dart';

class MockCarePlanRepository extends Mock implements CarePlanRepository {}

void main() {
  late CreateCarePlanUseCase useCase;
  late MockCarePlanRepository mockRepository;

  setUp(() {
    mockRepository = MockCarePlanRepository();
    useCase = CreateCarePlanUseCase(mockRepository);
    registerFallbackValue(
      CarePlanEntity(
        id: '1',
        title: 'dummy',
        description: 'dummy',
        doctorId: 'doc1',
        patientId: 'pat1',
        startDate: DateTime.now(),
      ),
    );
  });

  // Create a valid date for testing
  final tDate = DateTime.now();
  final tValidPlan = CarePlanEntity(
    id: '1',
    title: 'Test Plan',
    description: 'Description',
    doctorId: 'doctor1',
    patientId: 'patient1',
    startDate: tDate,
  );

  final tInvalidPlan = CarePlanEntity(
    id: '1',
    title: '',
    description: 'Description',
    doctorId: 'doctor1',
    patientId: 'patient1',
    startDate: tDate,
  );

  test('should return InvalidDataFailure when title is empty', () async {
    // Act
    final result = await useCase(tInvalidPlan);

    // Assert
    expect(result, const Left(InvalidDataFailure('Title cannot be empty')));
    verifyZeroInteractions(mockRepository);
  });

  test('should call repository when data is valid', () async {
    // Arrange
    when(
      () => mockRepository.createPlan(any()),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(tValidPlan);

    // Assert
    expect(result, const Right(unit));
    verify(() => mockRepository.createPlan(tValidPlan)).called(1);
  });
}
