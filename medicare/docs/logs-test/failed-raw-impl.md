# Raw implementation by IA - Arch Test Validation

## 🏗️ Relatório de Testes de Arquitetura

**Status:** ❌ Falha (Some tests failed)
**Comando:** `flutter test test/arch_test/architecture_test.dart`

### 🚩 Violações Encontradas

Abaixo está o resumo dos arquivos que estão quebrando as regras de arquitetura (Clean Architecture):

#### 1. Regra: Isolamento do Domínio

> O *Domain* não pode depender de *Infra* ou *UI*.

* **Arquivo Violador:** `lib/features/care_plan/domain/repositories/care_plan_repository.dart`
* ❌ **Import Proibido:** `../../infra/models/task_log.dart`
* **Motivo:** O repositório (Domain) está importando um modelo de implementação (Infra).



#### 2. Regra: Camada de Apresentação

> A *Presentation* (UI/ViewModel) não pode depender diretamente de *Infra*.

* **Arquivo Violador:** `lib/features/home/ui/view_model/patient_detail_view_model.dart`
* ❌ **Import Proibido:** `package:parse_server_sdk_flutter/...` (Package externo/Infra)
* ❌ **Import Proibido:** `../../../care_plan/infra/models/task_log.dart` (Model de Infra)


* **Arquivo Violador:** `lib/features/auth/ui/view_model/auth_view_model.dart`
* ❌ **Import Proibido:** `package:parse_server_sdk_flutter/...` (Package externo/Infra)



---

### 📝 Log Original Formatado

```bash
00:01 +0 -1: Architecture Compliance Rule 1: Domain Isolation (No Infra/Presentation in Domain) [E]

  Domain Isolation Violations Found:
  File lib/features/care_plan/domain/repositories/care_plan_repository.dart imports ../../infra/models/task_log.dart (Domain cannot import Infra/UI)
  
  package:matcher                            fail
  test/arch_test/architecture_test.dart 55:9  main.<fn>.<fn>


00:01 +1 -2: Architecture Compliance Rule 3: Presentation Layer (No Infra in Presentation) [E]

  Presentation Layer Violations Found:
  File lib/features/home/ui/view_model/patient_detail_view_model.dart imports package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart (Presentation cannot import Infra)
  File lib/features/home/ui/view_model/patient_detail_view_model.dart imports ../../../care_plan/infra/models/task_log.dart (Presentation cannot import Infra)
  File lib/features/auth/ui/view_model/auth_view_model.dart imports package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart (Presentation cannot import Infra)
  
  package:matcher                             fail
  test/arch_test/architecture_test.dart 105:9  main.<fn>.<fn>

00:01 +2 -2: Some tests failed.

```

---

### 🔄 Comandos para Retestar (Unitários)

Para rodar apenas os testes que falharam isoladamente:

**Regra 1 (Domain Isolation):**

```bash
dart test test/arch_test/architecture_test.dart -p vm --plain-name 'Architecture Compliance Rule 1: Domain Isolation (No Infra/Presentation in Domain)'

```

**Regra 3 (Presentation Layer):**

```bash
dart test test/arch_test/architecture_test.dart -p vm --plain-name 'Architecture Compliance Rule 3: Presentation Layer (No Infra in Presentation)'

```

---

**Você gostaria que eu explicasse como aplicar a Inversão de Dependência (DIP) para corrigir a importação do `parse_server_sdk` na sua ViewModel?**