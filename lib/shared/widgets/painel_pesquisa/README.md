# PainelPesquisa

Painel inferior genérico para pesquisar e renderizar itens de qualquer tipo. Ele preserva a pesquisa fuzzy e o destaque do componente original, mas também aceita widgets complexos, ações no cabeçalho e alterações na lista enquanto está aberto.

Importe o arquivo de exportações:

```dart
import 'package:mercado_list/shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';
```

## Item padrão e seleção

```dart
final resultado = await PainelPesquisa.exibir<Produto>(
  context: context,
  itens: produtos,
  obterTextoPesquisa: (produto) => produto.nome,
  obterIdentificador: (produto) => produto.id,
  modoSelecao: ModoInteracaoPainel.unica,
  titulo: 'Selecionar produto',
);
```

Os modos disponíveis são:

- `semSelecao`: apenas pesquisa e renderização; apropriado para listas com menus e ações próprias.
- `unica`: fecha o painel assim que um item é escolhido.
- `multipla`: permite escolher vários itens e confirmar no rodapé.

## Widget customizado e lista mutável

`construirItem` recebe um `ContextoItemPesquisa<T>`. Ele contém o item, o termo digitado, o estado de seleção e operações para atualizar ou remover o item do painel.

Nos modos `unica` e `multipla`, o painel aplica o gesto de seleção também ao widget customizado. Se o item possuir um menu de contexto, use toque longo para abrir o menu e preserve o toque simples para selecionar. No modo `semSelecao`, todos os gestos ficam sob responsabilidade do widget customizado.

Para fluxos que alternam dinamicamente entre menu e seleção, use `gerenciarGestosItemCustomizado: false` e controle os gestos no renderer. `construirRodape` permite renderizar ações que observam a seleção atual sem fechar o painel. Os parâmetros `fecharAoTocarFora` e `fecharAoArrastar` controlam se o modal pode ser dispensado sem usar o botão de fechar.

```dart
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

PainelPesquisa.exibir<Produto>(
  context: context,
  itens: produtos,
  obterTextoPesquisa: (produto) => produto.nome,
  obterIdentificador: (produto) => produto.id,
  modoSelecao: ModoInteracaoPainel.semSelecao,
  construirItem: (context, resultado) {
    return MeuCardProduto(
      produto: resultado.item,
      termoPesquisa: resultado.termoPesquisa,
      aoExcluir: resultado.remover,
    );
  },
  construirAcoesCabecalho: (context, controlador) => [
    IconButton(
      icon: const Icon(PhosphorIcons.plus),
      onPressed: () async {
        final produto = await criarProduto();
        controlador.adicionarItem(produto);
      },
    ),
  ],
);
```

O controlador também oferece `atualizarItem`, `substituirItens` e `notificarItemAlterado`. Informe `obterIdentificador` quando os objetos puderem ser substituídos por novas instâncias, para manter identidade e seleção estáveis.

## Outros recursos

- Pesquisa por prefixo, substring e similaridade, com ordenação por relevância.
- Destaque do termo pesquisado através de `TextoDestacadoPesquisa`.
- Carregamento assíncrono opcional.
- Itens padrão com subtítulo e ícone opcionais.
- Estilos configuráveis por `EstiloPainelPesquisa`.
- Painel arrastável com posições de 30%, 60%, 90% e 100%.
