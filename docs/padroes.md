# Padrões

## Nomenclatura

- Arquivos: snake_case
- Classes: PascalCase
- Métodos: camelCase

## Commits

- feat: somente quando uma funcionalidade utilizável foi adicionada.
- fix: somente para corrigir um comportamento incorreto.
- refactor: somente quando você reorganizar o código sem mudar o funcionamento.
- docs: exclusivamente para documentação.
- chore: configuração, dependências, organização e manutenção do projeto.

## Arquitetura

- Screen nunca acessa Repository.
- Repository nunca conhece a UI.
- Service concentra regras de negócio.
- Controller é o Provider.
