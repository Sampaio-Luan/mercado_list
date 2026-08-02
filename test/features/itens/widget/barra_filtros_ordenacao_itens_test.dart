import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/ordem.dart';
import 'package:mercado_list/core/constants/enums/ordenar_por.dart';
import 'package:mercado_list/core/constants/enums/prioridade.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/model/filtro_itens.dart';
import 'package:mercado_list/features/itens/widget/barra_filtros_ordenacao_itens.dart';

void main() {
  testWidgets('exibe resumos padrão compactos e ações nas extremidades',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
              aoAbrirFiltros: () => abriuFiltros = true,
              aoLimparFiltros: () {},
              aoAbrirOrdenacao: () => abriuOrdenacao = true,
              aoLimparOrdenacao: () {},
            ),
          ),
        ),
      ),
    );

    final resumoFiltro = find.byKey(
      const ValueKey('resumo-filtros-itens'),
    );
    final resumoOrdenacao = find.byKey(
      const ValueKey('resumo-ordenacao-itens'),
    );
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Nome / Crescente'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    for (final finder in [resumoFiltro, resumoOrdenacao]) {
      final chip = tester.widget<InputChip>(finder);
      expect(chip.padding, EdgeInsets.zero);
      expect(
        chip.visualDensity,
        const VisualDensity(horizontal: -4, vertical: -4),
      );
      expect(chip.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(chip.onDeleted, isNull);
    }

    final filtro = find.byKey(const ValueKey('mais-filtros-itens'));
    final divisor = find.byKey(
      const ValueKey('divisor-filtro-ordenacao-itens'),
    );
    final ordenacao = find.byKey(const ValueKey('ordenar-itens'));
    expect(tester.getCenter(filtro).dx, lessThan(tester.getCenter(divisor).dx));
    expect(
      tester.getCenter(divisor).dx,
      lessThan(tester.getCenter(ordenacao).dx),
    );

    await tester.tap(resumoFiltro);
    await tester.tap(resumoOrdenacao);
    expect(abriuFiltros, isTrue);
    expect(abriuOrdenacao, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('consolida filtros e ordenação e permite restaurar ambos',
      (tester) async {
    var limpouFiltros = false;
    var limpouOrdenacao = false;
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
              aoAbrirFiltros: () {},
              aoLimparFiltros: () => limpouFiltros = true,
              aoAbrirOrdenacao: () {},
              aoLimparOrdenacao: () => limpouOrdenacao = true,
            ),
          ),
        ),
      ),
    );

    final resumoFiltro = find.byKey(
      const ValueKey('resumo-filtros-itens'),
    );
    final resumoOrdenacao = find.byKey(
      const ValueKey('resumo-ordenacao-itens'),
    );
    expect(
      find.text('Pendentes / Com preço / P: Alta / Cat: Higiene'),
      findsOneWidget,
    );
    expect(find.text('Preço / Decrescente'), findsOneWidget);

    tester.widget<InputChip>(resumoFiltro).onDeleted!();
    tester.widget<InputChip>(resumoOrdenacao).onDeleted!();
    expect(limpouFiltros, isTrue);
    expect(limpouOrdenacao, isTrue);

    final ordenar = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordenar-itens')),
    );
    expect(
      ordenar.style?.backgroundColor?.resolve({}),
      Colors.indigo.withAlpha(28),
    );
    expect(
      ordenar.style?.side?.resolve({}),
      BorderSide(color: Colors.indigo.withAlpha(180)),
    );
  });
}
