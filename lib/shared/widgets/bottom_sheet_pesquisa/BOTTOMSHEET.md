# BottomSheetPesquisaGenerica

Componente Flutter **genérico, reutilizável e estilizável** para exibir um `showModalBottomSheet` com pesquisa em tempo real, ordenação por relevância (fuzzy search) e seleção única ou múltipla de qualquer tipo `T`.

Todo o código (classes, variáveis, métodos, enums) segue nomenclatura em **Português Brasileiro**, mas o componente funciona com qualquer tipo de dado: classes próprias, `String`, `int`, enums, etc.

---

## 📁 Estrutura de pastas

```structure
lib/
├── main.dart                                  # App de exemplo executável
├── componentes/
│   └── bottom_sheet_pesquisa_generica/
│       ├── bottom_sheet_pesquisa_generica.dart            # Widget principal (StatefulWidget + método estático exibir)
│       ├── bottom_sheet_pesquisa_generica_exportacoes.dart # Barrel file (importe só este!)
│       ├── cabecalho_bottom_sheet.dart                     # Cabeçalho fixo (título + botões)
│       ├── campo_pesquisa.dart                             # Barra de pesquisa fixa
│       ├── controlador_pesquisa_generica.dart              # ChangeNotifier com a lógica de estado
│       ├── estilo_bottom_sheet_pesquisa.dart               # Classe de customização visual
│       ├── item_lista_pesquisa.dart                        # Tile de cada item da lista
│       ├── modo_selecao.dart                               # Enum ModoSelecao + PontosAncoragemAltura
│       ├── rodape_confirmacao_selecao.dart                 # Rodapé com botão "Confirmar" + estado vazio
│       ├── texto_com_destaque_pesquisa.dart                # Widget de highlight do texto pesquisado
│       └── utilitario_similaridade_texto.dart              # Algoritmo Levenshtein + Jaro-Winkler + normalização
└── exemplo/
    └── tela_exemplo_bottom_sheet_pesquisa.dart   # Tela de exemplo com 3 cenários de uso
```

---

## 🚀 Uso básico

Importe apenas o arquivo de exportações (barrel file):

```dart
import 'package:seu_app/componentes/bottom_sheet_pesquisa_generica/bottom_sheet_pesquisa_generica_exportacoes.dart';
```

### Seleção múltipla (padrão)

```dart
final resultado = await BottomSheetPesquisaGenerica.exibir<EstadoBrasileiro>(
  context: context,
  itens: listaDeEstados,
  obterTextoExibicao: (estado) => estado.nome,
  obterTextoSubtitulo: (estado) => estado.sigla,
  titulo: 'Selecionar Estados',
);

if (resultado != null && resultado is List<EstadoBrasileiro>) {
  // resultado contém os itens selecionados
}
```

### Seleção única

```dart
final resultado = await BottomSheetPesquisaGenerica.exibir<String>(
  context: context,
  itens: ['Maçã', 'Banana', 'Uva'],
  obterTextoExibicao: (fruta) => fruta,
  modoSelecao: ModoSelecao.unica,
  titulo: 'Selecionar Fruta',
);

if (resultado != null && resultado is String) {
  // resultado é o item único selecionado
}
```

### Carregamento assíncrono

```dart
final resultado = await BottomSheetPesquisaGenerica.exibir<Produto>(
  context: context,
  obterTextoExibicao: (produto) => produto.nome,
  carregarItensAssincronamente: () => repositorio.buscarProdutos(),
  modoSelecao: ModoSelecao.unica,
);
```

> Quando `carregarItensAssincronamente` é fornecido, o parâmetro `itens` é ignorado e um indicador de carregamento (`CircularProgressIndicator`) é exibido automaticamente até a resolução do `Future`.

---

## 🎨 Customização visual

Use `EstiloBottomSheetPesquisa` para customizar cores, ícones, raios de borda e estilos de texto sem alterar o componente:

```dart
BottomSheetPesquisaGenerica.exibir<Produto>(
  context: context,
  itens: produtos,
  obterTextoExibicao: (p) => p.nome,
  estilo: EstiloBottomSheetPesquisa(
    corFundo: Colors.white,
    corItemSelecionado: Colors.indigo.shade50,
    corIconeSelecionado: Colors.indigo,
    raioBordaSuperior: 28,
    raioBordaCampoPesquisa: 20,
    estiloTextoItemDestacado: const TextStyle(
      color: Colors.deepOrange,
      fontWeight: FontWeight.w900,
    ),
    iconePesquisa: Icons.travel_explore_rounded,
  ),
);
```

### Outras dicas de customização

| O que customizar | Como fazer |
| **Texto/legendas (i18n)** | Todos os textos (`titulo`, `textoPlaceholderPesquisa`, `textoListaVazia`, `textoSemResultados`, `textoBotaoConfirmar`) são parâmetros — basta passar outro idioma. |
| **Subtítulo do item** | Forneça `obterTextoSubtitulo: (item) => ...` (ex.: CPF, categoria, e-mail). |
| **Ícone/avatar à esquerda** | Forneça `construirIconeLideranca: (item) => CircleAvatar(...)`. |
| **Sensibilidade da busca fuzzy** | Ajuste `pontuacaoMinimaRelevancia` (0.0 a 1.0). Valores menores trazem mais resultados "parecidos"; valores maiores exigem correspondência mais exata. |
| **Esconder botão de confirmar (múltipla)** | `exibirRodapeConfirmacao: false` — útil se você quiser confirmar a seleção fechando manualmente o sheet em outro botão da própria tela. |
| **Tema escuro** | O componente já herda cores do `Theme.of(context).colorScheme`; basta configurar `darkTheme` no `MaterialApp`. |
| **Pontos de ancoragem (snaps)** | Definidos em `PontosAncoragemAltura` (30/60/90/100%). Para alterar, edite as constantes nessa classe. |

---

## ⚙️ Detalhes de implementação

- **Algoritmo de similaridade**: implementado em `utilitario_similaridade_texto.dart`. Prefixo e substring exatos têm prioridade máxima; o fallback fuzzy usa **distância de Levenshtein por palavra** (com tolerância de edições proporcional ao tamanho do termo pesquisado), o que é mais previsível que Jaro-Winkler puro para erros de digitação — evita falsos positivos como termos curtos "combinando" com palavras longas sem relação real. O Jaro-Winkler também está implementado e disponível como utilitário público (`calcularSimilaridadeJaroWinkler`), caso queira usá-lo em outro contexto.
- **Destaque de texto**: `TextoComDestaquePesquisa` localiza os intervalos coincidentes no texto **original** (com acentos/caixa preservados) comparando contra a versão normalizada, e usa `Text.rich`/`TextSpan` para aplicar negrito + cor primária apenas nesses trechos.
- **Performance**: a lista usa `ListView.builder`, construindo apenas os itens visíveis. O recalculo de filtro/ordenação ocorre apenas no `ControladorPesquisaGenerica` (um `ChangeNotifier`), evitando rebuilds desnecessários de toda a árvore de widgets.
- **Arraste e tela cheia**: implementado com `DraggableScrollableSheet` (`snap: true`, `snapSizes` em 30/60/90/100%) e um `DraggableScrollableController` para animar programaticamente ao tocar no botão de tela cheia. O sheet usa `expand: true` (padrão) e não é envolvido em nenhum `Container` com altura fixa — isso é importante: limitar a altura manualmente faz o sheet calcular sua fração de tamanho com base no espaço errado, e o `animateTo` programático (botão) passa a não corresponder ao que o gesto de arrastar produz. O controller também verifica `isAttached` antes de chamar `animateTo`/`size`, evitando que um toque muito rápido no botão (antes do primeiro frame do sheet) seja silenciosamente ignorado.
- **Teclado**: o sheet é envolvido em um `AnimatedPadding` que reage a `MediaQuery.viewInsets.bottom`, subindo suavemente quando o teclado aparece.
- **Seleção**: `ModoSelecao.multipla` (padrão) usa `Checkbox` por item e exige confirmação via rodapé; `ModoSelecao.unica` usa um ícone de círculo e fecha o sheet imediatamente ao tocar no item.
- **Genérico de verdade**: como o `Set<T>` interno depende de `==`/`hashCode`, para classes próprias é recomendável sobrescrever esses operadores (ou usar pacotes como `equatable`) caso duas instâncias representem o "mesmo" item lógico.

---

## ▶️ Como executar o exemplo

```bash
flutter pub get
flutter run
```

A tela inicial (`TelaExemploBottomSheetPesquisa`) mostra três cartões, cada um abrindo o bottom sheet em um cenário diferente: seleção múltipla de Estados, seleção única de frutas e carregamento assíncrono simulado.
