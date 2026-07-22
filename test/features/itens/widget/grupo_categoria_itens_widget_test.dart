import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/model/categoria_com_itens_model.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/widget/grupo_categoria_itens_widget.dart';
import 'package:mercado_list/features/itens/widget/item_da_lista_widget.dart';

void main() {
  testWidgets('usa cor da categoria e exibe subtotal e total marcado no rodapé',
      (tester) async {
    const corCategoria = Colors.green;
    final grupo = CategoriaComItens(
      categoria: Categoria(
        id: 1,
        titulo: 'Hortifruti',
        cor: corCategoria,
        ordem: 1,
      ),
      itens: [
        Item(
          id: 1,
          idLista: 1,
          idCategoria: 1,
          titulo: 'Banana',
          quantidade: 2,
          preco: 500,
          obtido: true,
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GrupoCategoriaItensWidget(
          grupo: grupo,
          chaveEstado: 'estado-expansao-v2-lista-1-categoria-1-versao-0',
          inicialmenteExpandido: true,
          aoAlterarExpansao: (_) {},
          aoAlterarMarcacao: (_, _) {},
          aoEditar: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final expansionTile = tester.widget<ExpansionTile>(
      find.byType(ExpansionTile),
    );
    expect(expansionTile.backgroundColor, corCategoria);
    expect(expansionTile.collapsedBackgroundColor, corCategoria);
    expect(
      expansionTile.key,
      isA<PageStorageKey<String>>().having(
        (key) => key.value,
        'valor',
        'estado-expansao-v2-lista-1-categoria-1-versao-0',
      ),
    );
    expect(
        find.byKey(const ValueKey('rolagem-interna-categoria')), findsNothing);
    expect(find.text('Subtotal'), findsOneWidget);
    final subtotalTitulo = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.data?.contains('Subtotal') ?? false) &&
          (widget.data?.contains('10,00') ?? false),
    );
    expect(subtotalTitulo, findsNothing);
    expect(find.text('Total'), findsOneWidget);
    expect(find.textContaining('10,00'), findsAtLeastNWidgets(1));

    final detalhe = find.descendant(
      of: find.byType(ItemDaListaWidget),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('2 und') ?? false) &&
            (widget.data?.contains('5,00') ?? false),
      ),
    );
    final totalItem = find.descendant(
      of: find.byType(ItemDaListaWidget),
      matching: find.byWidgetPredicate(
        (widget) => widget is Text && (widget.data?.contains('10,00') ?? false),
      ),
    );
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: detalhe, matching: find.byType(Opacity)).first,
          )
          .opacity,
      .6,
    );
    expect(
      tester
          .widget<Opacity>(
            find.ancestor(of: totalItem, matching: find.byType(Opacity)).first,
          )
          .opacity,
      .9,
    );

    final materiais = tester.widgetList<Material>(
      find.ancestor(of: find.text('Banana'), matching: find.byType(Material)),
    );
    expect(
      materiais.any((material) => material.color == corCategoria.withAlpha(28)),
      isTrue,
    );

    await tester.tap(find.text('Hortifruti'));
    await tester.pumpAndSettle();
    expect(subtotalTitulo, findsOneWidget);
    await tester.tap(find.text('Hortifruti'));
    await tester.pumpAndSettle();
    expect(subtotalTitulo, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('limita categorias extensas a cinco linhas com rolagem interna',
      (tester) async {
    final grupo = CategoriaComItens(
      categoria: Categoria(
        id: 2,
        titulo: 'Mercearia',
        cor: Colors.orange,
        ordem: 2,
      ),
      itens: List.generate(
        6,
        (indice) => Item(
          id: indice + 1,
          idLista: 1,
          idCategoria: 2,
          titulo: 'Item ${indice + 1}',
        ),
      ),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GrupoCategoriaItensWidget(
          grupo: grupo,
          chaveEstado: 'estado-expansao-v2-lista-1-categoria-2-versao-0',
          inicialmenteExpandido: true,
          aoAlterarExpansao: (_) {},
          aoAlterarMarcacao: (_, _) {},
          aoEditar: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final area = find.byKey(const ValueKey('rolagem-interna-categoria'));
    expect(area, findsOneWidget);
    expect(tester.getSize(area).height, 270);
    final lista = tester.widget<ListView>(
      find.descendant(of: area, matching: find.byType(ListView)),
    );
    expect(lista.primary, isFalse);
    expect(lista.physics, isA<ClampingScrollPhysics>());
    final indicador = tester.widget<Scrollbar>(
      find.byKey(const ValueKey('indicador-rolagem-categoria')),
    );
    expect(indicador.thumbVisibility, isTrue);
    expect(indicador.controller, same(lista.controller));
    expect(
      lista.key,
      isA<PageStorageKey<String>>().having(
        (key) => key.value,
        'valor',
        'rolagem-estado-expansao-v2-lista-1-categoria-2-versao-0',
      ),
    );

    await tester.drag(
      find.descendant(of: area, matching: find.byType(ListView)),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mercearia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mercearia'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
