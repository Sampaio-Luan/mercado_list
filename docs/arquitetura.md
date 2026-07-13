# Arquitetura

Fluxo da aplicação:

Screen
↓
Controller
↓
Service
↓
Repository
↓
SQLite

Responsabilidades:

- Controller: gerencia estado da UI.
- Service: regras de negócio.
- Repository: acesso aos dados.
- Mapper: conversão entre modelos e banco.
