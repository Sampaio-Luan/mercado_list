import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/ordem.dart';
import 'package:mercado_list/core/constants/enums/ordenar_por.dart';
import 'package:mercado_list/core/constants/enums/prioridade.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/model/filtro_itens.dart';
import 'package:mercado_list/features/itens/widget/barra_filtros_ordenacao_itens.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

void main() {
  testWidgets('exibe situações rápidas e ordenação em um único controle',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SituacaoItem? situacaoSelecionada;
    var abriuFiltros = false;
    var abriuOrdenacao = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: BarraFiltrosOrdenacaoItens(
              habilitada: true,
              filtro: const FiltroItens(),
              categorias: const [],
              ordenarPor: OrdenarPor.nome,
              ordem: Ordem.ascendente,
              corLista: Colors.indigo,
              aoAlterarSituacao: (valor) => situacaoSelecionada = valor,
              aoAbrirFiltros: () => abriuFiltros = true,
              aoLimparFiltros: () {},
              aoAbrirOrdenacao: () => abriuOrdenacao = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('situacao-itens-todos')),
          )
          .selected,
      isTrue,
    );
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Marcados'), findsOneWidget);
    expect(find.byKey(const ValueKey('resumo-filtros-itens')), findsNothing);

    final ordenacao = find.byKey(const ValueKey('ordenar-itens'));
    final chipOrdenacao = tester.widget<InputChip>(ordenacao);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.byIcon(PhosphorIcons.sortAscending), findsOneWidget);
    expect(chipOrdenacao.backgroundColor, Colors.transparent);
    expect(chipOrdenacao.side, const BorderSide(color: Colors.indigo));
    expect(chipOrdenacao.labelStyle?.color, Colors.indigo);

    await tester.tap(find.byKey(const ValueKey('situacao-itens-pendentes')));
    await tester.tap(find.byKey(const ValueKey('mais-filtros-itens')));
    await tester.tap(ordenacao);
    expect(situacaoSelecionada, SituacaoItem.pendentes);
    expect(abriuFiltros, isTrue);
    expect(abriuOrdenacao, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('consolida filtros adicionais e mantém ordenação delineada',
      (tester) async {
    var limpouFiltros = false;
    final filtro = FiltroItens(
      situacao: SituacaoItem.pendentes,
      idCategoria: 1,
      prioridade: Prioridade.alta,
      possuiPreco: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: BarraFiltrosOrdenacaoItens(
              habilitada: true,
              filtro: filtro,
              categorias: [
                Categoria(
                  id: 1,
                  titulo: 'Higiene',
                  cor: Colors.blue,
                  ordem: 1,
                ),
              ],
              ordenarPor: OrdenarPor.preco,
              ordem: Ordem.descendente,
              corLista: Colors.indigo,
              aoAlterarSituacao: (_) {},
              aoAbrirFiltros: () {},
              aoLimparFiltros: () => limpouFiltros = true,
              aoAbrirOrdenacao: () {},
            ),
          ),
        ),
      ),
    );

    final resumoFiltro = find.byKey(
      const ValueKey('resumo-filtros-itens'),
    );
    expect(find.byType(ChoiceChip), findsNothing);
    expect(
      find.text('Pendentes / Com preço / P: Alta / Cat: Higiene'),
      findsOneWidget,
    );
    expect(find.text('Preço'), findsOneWidget);
    expect(find.textContaining('Decrescente'), findsNothing);
    expect(find.byIcon(PhosphorIcons.sortDescending), findsOneWidget);
    final ordenacao = tester.widget<InputChip>(
      find.byKey(const ValueKey('ordenar-itens')),
    );
    expect(ordenacao.backgroundColor, Colors.transparent);
    expect(ordenacao.side, const BorderSide(color: Colors.indigo));

    tester.widget<InputChip>(resumoFiltro).onDeleted!();
    expect(limpouFiltros, isTrue);
  });

  testWidgets('substitui cor clara sem contraste pela cor sobre a superfície',
      (tester) async {
    final tema = ThemeData.light().copyWith(
      colorScheme: ThemeData.light().colorScheme.copyWith(
            surface: Colors.white,
            onSurface: Colors.black,
          ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: tema,
        home: Scaffold(
          body: BarraFiltrosOrdenacaoItens(
            habilitada: true,
            filtro: const FiltroItens(),
            categorias: const [],
            ordenarPor: OrdenarPor.nome,
            ordem: Ordem.ascendente,
            corLista: Colors.yellow,
            aoAlterarSituacao: (_) {},
            aoAbrirFiltros: () {},
            aoLimparFiltros: () {},
            aoAbrirOrdenacao: () {},
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('mais-filtros-itens')),
          )
          .style
          ?.foregroundColor
          ?.resolve({}),
      Colors.black,
    );
    final ordenacao = tester.widget<InputChip>(
      find.byKey(const ValueKey('ordenar-itens')),
    );
    expect(ordenacao.side, const BorderSide(color: Colors.black));
    expect(ordenacao.labelStyle?.color, Colors.black);
  });
}
