# Arquitetura do Sistema Medicare

Este projeto adota a **Arquitetura Limpa (Clean Architecture)** adaptada para o ecossistema Flutter, priorizando a desacoplamento, testabilidade e manutenibilidade.

## 1. Princípios Fundamentais

### A Regra de Dependência
A regra dourada deste projeto é: **O código nas camadas internas não deve saber nada sobre as camadas externas.** O fluxo de dependência aponta sempre para dentro (para o Domínio).

1.  **Domínio (Domain)**: O núcleo da aplicação. Não conhece ninguém.
2.  **Infraestrutura (Infra)**: Conhece o Domínio.
3.  **Apresentação (Presentation)**: Conhece o Domínio.

### Inversão de Controle (IoC)
Utilizamos injeção de dependência rigorosa. Nenhum Caso de Uso (`UseCase`) deve instanciar um Repositório concretamente. Eles devem receber o contrato (interface) via construtor.

---

## 2. Detalhamento das Camadas

### 🟡 Camada de Domínio (`domain`)
Esta é a camada mais crítica e estável do sistema.
-   **Responsabilidade:** Conter a lógica de negócio pura e as regras corporativas.
-   **Conteúdo Típico:**
    -   `entities/`: Objetos de negócio puros e imutáveis.
    -   `repositories/`: Interfaces (contratos abstratos) dos repositórios.
    -   `usecases/`: Classes que encapsulam uma única ação de negócio (ex: `LoginUserUseCase`).
-   **🚫 RESTRIÇÃO CRÍTICA:** É estritamente **PROIBIDO** importar pacotes do Flutter (`package:flutter/material.dart`, widgets), implementações de banco de dados ou bibliotecas externas nesta camada. Deve ser **Dart puro**.

### 🟢 Camada de Infraestrutura (`infra`)
Esta camada suporta o domínio, lidando com dados e o mundo externo.
-   **Responsabilidade:** Implementar as interfaces definidas no Domínio, serializar dados e comunicar com APIs/Bancos.
-   **Conteúdo Típico:**
    -   `models/`: Classes que estendem as Entidades e adicionam métodos de serialização (`toJson`, `fromJson`).
    -   `repositories/`: Implementação concreta dos contratos definidos no domínio.
    -   `datasources/`: Comunicação direta com APIs (Dio, Http) ou Banco Local (Hive, SQLite).
-   **Dependências:** Conhece a camada de Domínio e bibliotecas externas.

### 🔵 Camada de Apresentação (`presentation`)
Esta é a camada volátil que o usuário vê.
-   **Responsabilidade:** Renderizar a interface, gerenciar inputs e o estado da UI.
-   **Conteúdo Típico:**
    -   `pages/`: Telas do aplicativo.
    -   `widgets/`: Componentes visuais reutilizáveis.
    -   `controllers/` (ou `blocs`/`stores`): Gerenciamento de estado que chama os UseCases.
-   **Dependências:** Depende da camada de Domínio para executar lógicas de negócio.

---

## 3. Organização de Pastas (Feature-First)

Não organizamos o projeto por camadas horizontais globais. Organizamos por **Funcionalidades (Features)**. Cada funcionalidade encapsula suas próprias camadas de clean architecture.

### Estrutura de Diretórios Esperada:

```text
lib/
└── features/
    ├── <nome_da_feature>/       <-- Ex: 'auth', 'chat', 'schedule'
    │   ├── domain/              <-- Núcleo da Feature
    │   │   ├── entities/
    │   │   ├── repositories/    <-- Apenas interfaces (abstract class)
    │   │   └── usecases/
    │   ├── infra/               <-- Dados da Feature
    │   │   ├── datasources/
    │   │   ├── models/          <-- Extende as Entities do domain
    │   │   └── repositories/    <-- Implementa interface do domain
    │   └── presentation/        <-- UI da Feature
    │       ├── controllers/
    │       └── pages/
    └── ...