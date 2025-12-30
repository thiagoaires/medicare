
# Padrões de Projeto e Estilo de Código

Este documento serve como referência de implementação para o projeto Medicare. Utilize estes padrões para manter a consistência cognitiva e técnica do código.

## 1. Tratamento de Erros Funcional (`dartz`)

**Contexto:** Não utilizamos `try/catch` nas camadas de Domínio ou Apresentação para fluxo de controle. Exceções devem ser capturadas na camada de `Infra` (Repository Implementation) e convertidas para `Failures`.

**Regra:** Todos os Repositórios e UseCases devem retornar `Future<Either<Failure, Type>>`.

**Exemplo (Contrato do Repositório):**
```dart
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/patient_entity.dart';

abstract class PatientRepository {
  // Retorna ESQUERDA (Failure) ou DIREITA (Sucesso)
  Future<Either<Failure, PatientEntity>> getPatientDetails(String id);
}

```

---

## 2. Padrão de Casos de Uso (UseCases)

**Contexto:** UseCases representam uma única ação de negócio. Eles devem ser "Callable Classes".

**Regra:**

1. Deve ter apenas um método público chamado `call`.
2. Deve receber dependências via construtor (Injeção de Dependência).

**Exemplo:**

```dart
class GetPatientDetailsUseCase {
  final PatientRepository repository;

  GetPatientDetailsUseCase(this.repository);

  // Permite chamar usecase(id) diretamente
  Future<Either<Failure, PatientEntity>> call(String id) async {
    return await repository.getPatientDetails(id);
  }
}

```

---

## 3. Entidades vs. Models

**Contexto:** Separamos estritamente os objetos de negócio puros (Entities) dos objetos de transporte de dados (Models).

### 3.1 Entidades (Domain)

**Regra:** Classes puras, imutáveis, com construtor `const` e **SEM** métodos de serialização (`toJson`/`fromJson`). Devem implementar `Equatable` para comparação de valor.

```dart
import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String name;
  final String medicalRecordNumber;

  const PatientEntity({
    required this.id,
    required this.name,
    required this.medicalRecordNumber,
  });

  @override
  List<Object?> get props => [id, name, medicalRecordNumber];
}

```

### 3.2 Models (Infra)

**Regra:** Estendem as Entidades e adicionam a responsabilidade de Serialização (JSON) e mapeamento (Mappers).

```dart
import '../entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required String id,
    required String name,
    required String medicalRecordNumber,
  }) : super(
          id: id,
          name: name,
          medicalRecordNumber: medicalRecordNumber,
        );

  // Factory para criar a partir de JSON
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      name: json['name'],
      medicalRecordNumber: json['prontuario_id'], // Mapeamento de chaves
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prontuario_id': medicalRecordNumber,
    };
  }
}

```

---

## 4. Implementação de Repositórios (Infra)

**Contexto:** É onde ocorre a "mágica" de tratar erros e converter Models em Entities.

**Regra:**

1. Captura exceções do Datasource.
2. Retorna `Right(Entity)` em caso de sucesso.
3. Retorna `Left(Failure)` em caso de erro.

**Exemplo:**

```dart
class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PatientEntity>> getPatientDetails(String id) async {
    try {
      // O Datasource retorna um Model
      final result = await remoteDataSource.fetchPatient(id);
      // O Repository retorna para o domínio como Entity (polimorfismo)
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}

```