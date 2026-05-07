# 🛒 Mercado List - Gerenciador Inteligente de Compras

[![Flutter Version](https://img.shields.io/badge/Flutter-3.16+-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.2+-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Um aplicativo completo para gerenciamento de listas de supermercado com recursos avançados de organização, categorização, histórico e exportação de dados.

## 📱 Screenshots

| Tela Principal  | Gerenciamento de Categorias | Exportação      |
|-----------------|-----------------------------|-----------------|
| (Adicione aqui) | (Adicione aqui)             | (Adicione aqui) |

## ✨ Funcionalidades Principais

### 📋 Gerenciamento de Listas

- ✅ Criar múltiplas listas de compras
- ✅ Duplicar listas existentes
- ✅ Arquivar e restaurar listas
- ✅ Compartilhar listas via texto

### 🏷️ Sistema de Categorias

- ✅ Criar e gerenciar categorias personalizadas
- ✅ Escolher cores distintas para cada categoria
- ✅ Definir hierarquia de exibição (ordem personalizada)
- ✅ Visualização de itens agrupados por categoria

### 🛍️ Gerenciamento de Itens

Cada item possui:

- ✏️ **Nome** do produto
- 📊 **Tipo de medida** (kg, L, un, pacote, etc.)
- 🔢 **Quantidade**
- 💰 **Preço** unitário
- ⭐ **Prioridade** (Baixa, Média, Alta)
- 🏷️ **Categoria** associada
- ✅ **Status** de compra (marcado/desmarcado)

### 📊 Cálculos e Totais

- 💵 **Total da lista** (todos os itens)
- ✅ **Total dos itens selecionados** (marcados como comprados)
- 📈 Subtotal por categoria

### 📜 Histórico

- 🕒 Armazenamento automático de histórico de compras
- 📅 Filtro por período (dia, semana, mês)
- 📊 Estatísticas de gastos por categoria
- 🔄 Comparação entre compras

### 🔍 Visualização e Filtros

- 🔎 **Pesquisa** por nome do produto
- 🏷️ **Filtro por categoria**
- ⭐ **Filtro por prioridade**
- ✅ Filtro por status (comprados/não comprados)
- 📱 Layout responsivo (lista, grade, compacto)

### 📤 Exportação

- 📄 **Gerar PDF** da lista/comprovante
- 📊 **Exportar para Excel** (.xlsx)
- 📝 **Compartilhar como texto** via WhatsApp, Email, etc.
- 💾 Backup em JSON

## 🚀 Tecnologias Utilizadas

- **Flutter** (SDK 3.16+)
- **Dart** (3.2+)
- **SQLite** (sqflite) - Armazenamento local
- **Provider / Riverpod** - Gerenciamento de estado
- **PDF** (printing + pdf) - Geração de PDF
- **Excel** (excel) - Exportação para Excel
- **Share Plus** - Compartilhamento nativo
- **Path Provider** - Gerenciamento de arquivos
- **Intl** - Formatação de datas e moedas

## 📦 Instalação

### Pré-requisitos

- Flutter SDK instalado e configurado
- Android Studio / VS Code
- Dispositivo ou emulador Android/iOS

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/marketlist.git

# Entre no diretório
cd marketlist

# Baixe as dependências
flutter pub get

# Execute o app
flutter run
```

### Build para produção

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🗂️ Estrutura do Projeto

``` text
lib/
├── models/
│   ├── list_model.dart
│   ├── category_model.dart
│   ├── item_model.dart
│   └── history_model.dart
├── database/
│   ├── database_helper.dart
│   └── migrations/
├── screens/
│   ├── home_screen.dart
│   ├── list_detail_screen.dart
│   ├── category_manager_screen.dart
│   ├── history_screen.dart
│   └── export_screen.dart
├── widgets/
│   ├── category_card.dart
│   ├── item_card.dart
│   ├── total_card.dart
│   └── filter_chip.dart
├── services/
│   ├── pdf_service.dart
│   ├── excel_service.dart
│   └── share_service.dart
├── providers/
│   ├── list_provider.dart
│   ├── category_provider.dart
│   └── item_provider.dart
└── utils/
    ├── constants.dart
    ├── helpers.dart
    └── validators.dart
```

## 🎯 Como Usar

### 1. Criando uma Lista

- Toque no botão "+" na tela inicial
- Digite o nome da lista
- Escolha uma cor (opcional)
- Toque em "Salvar"

### 2. Gerenciando Categorias

- Acesse "Configurações" → "Categorias"
- Toque em "+" para criar nova categoria
- Selecione uma cor e defina a ordem
- Arraste para reordenar a hierarquia

### 3. Adicionando Itens

- Selecione uma lista
- Toque em "Adicionar Item"
- Preencha nome, quantidade, preço
- Escolha categoria e prioridade
- Salve o item

### 4. Marcando Itens Comprados

- Toque no checkbox ao lado do item
- O total selecionado atualizará automaticamente
- Itens marcados vão para o final da categoria

### 5. Exportando Lista

- Abra uma lista
- Toque no ícone de compartilhar
- Escolha o formato (PDF, Excel, Texto)
- Selecione as opções desejadas

## 📊 Exemplos de Exportação

### PDF Gerado Inclui

- Cabeçalho com nome da lista e data
- Itens agrupados por categoria
- Quantidade, preço unitário e total por item
- Resumo com subtotais por categoria
- Total geral e total de itens comprados

### Excel Inclui

- Planilha principal com todos os itens
- Colunas formatadas
- Filtros automáticos
- Totais calculados

## 🔄 Próximas Funcionalidades

- [ ] Sincronização em nuvem
- [ ] Orçamento por lista
- [ ] Scanner de código de barras
- [ ] Listas colaborativas
- [ ] Sugestão baseada em histórico
- [ ] Dark mode completo
- [ ] Widgets para home screen
- [ ] Backup automático

## 🤝 Contribuição

Contribuições são bem-vindas! Siga estes passos:

1. Fork o projeto
2. Crie sua branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

## 📞 Contato

Luan Sampio - [ luansampaio.dev@mail.com ]

Link do Projeto: [https://github.com/seu-usuario/marketlist](https://github.com/seu-usuario/marketlist)

## 🙏 Agradecimentos

- Flutter team pela framework incrível
- Contribuidores de pacotes open-source
- Comunidade Flutter brasileira

## 🐛 Problemas Conhecidos

- (Liste problemas conhecidos, se houver)

## 📱 Compatibilidade

| Plataforma |        Versão Mínima    | Status |
|------------|-------------------------|--------|
| Android    | 5.0 (API 21)            | ✅     |
| iOS        | 🚧 (Em desenvolvimento) |        |

## Desenvolvido com ❤️ usando Flutter

## 📦 Pacotes Necessários (pubspec.yaml)

Para complementar, aqui estão as dependências que você precisará no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Banco de dados
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  
  # Gerenciamento de estado
  provider: ^6.1.0
  # ou riverpod: ^2.4.0
  
  # PDF
  pdf: ^3.10.0
  printing: ^5.11.0
  
  # Excel
  excel: ^2.0.0
  
  # Compartilhamento
  share_plus: ^7.2.0
  
  # Utilitários
  intl: ^0.18.0
  path: ^1.9.0
  
  # UI
  flutter_colorpicker: ^1.0.0
  draggable_home: ^1.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
