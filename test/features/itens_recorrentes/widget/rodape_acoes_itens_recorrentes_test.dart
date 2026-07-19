import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/itens_recorrentes/widget/rodape_acoes_itens_recorrentes.dart';

void main() {
  Widget construir(int quantidade) {
    return MaterialApp(
      home: Scaffold(
        body: RodapeAcoesItensRecorrentes(
          quantidadeSelecionada: quantidade,
          aoAdicionar: () {},
          aoMover: () {},
          aoCriarCategoria: () {},
          aoExcluir: () {},
        ),
      ),
    );
  }

  testWidgets('sem seleção apresenta apenas adicionar item', (tester) async {
    await tester.pumpWidget(construir(0));

    expect(find.text('Adicionar item recorrente'), findsOneWidget);
    expect(find.text('Mover'), findsNothing);
    expect(find.text('Nova categoria'), findsNothing);
    expect(find.text('Excluir'), findsNothing);
  });

  testWidgets('com seleção substitui adicionar pelas ações em lote',
      (tester) async {
    await tester.pumpWidget(construir(2));

    expect(find.text('Adicionar item recorrente'), findsNothing);
    expect(find.text('2 selecionados'), findsOneWidget);
    expect(find.text('Mover'), findsOneWidget);
    expect(find.text('Nova categoria'), findsOneWidget);
    expect(find.text('Excluir'), findsOneWidget);
  });
}
