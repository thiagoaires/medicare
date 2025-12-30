# Projeto Medicare - Documentação Central

Bem-vindo à documentação técnica do **Medicare**, uma aplicação de telemedicina para monitoramento pós-operatório desenvolvida em Flutter.

Este projeto segue rigorosamente os princípios da **Arquitetura Limpa (Clean Architecture)** e utiliza uma estratégia de **Documentação Orientada ao Contexto** para facilitar o desenvolvimento assistido por Inteligência Artificial.

## 📂 Estrutura de Documentação

Para garantir a conformidade arquitetural e a qualidade do código gerado, consulte os seguintes documentos antes de iniciar qualquer implementação:

- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Define as camadas do sistema (Domain, Infra, Presentation), as regras de dependência e a organização de pastas (*Feature-First*). **Leitura obrigatória para entender onde colocar cada arquivo.**
- **[PATTERNS.md](./PATTERNS.md)**: Contém os padrões de código, *snippets* de referência e bibliotecas obrigatórias (como `dartz` para tratamento de erros). **Use este guia para manter a consistência sintática.**
- **[ai-notes.md](./ai-notes.md)**: Diretrizes específicas para agentes de IA (Claude, Gemini, Copilot), incluindo limitações, regras de comportamento e "System Prompts" implícitos.

## 🎯 Objetivo do Projeto
O Medicare visa conectar médicos e pacientes cirúrgicos, permitindo o envio de planos de cuidados (medicação, dieta) e o feedback diário do paciente. O sistema prioriza **manutenibilidade**, **testabilidade** e **segurança**.