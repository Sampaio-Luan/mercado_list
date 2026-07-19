import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/shared/widgets/seletor_de_cor.dart';

void main() {
  testWidgets('abre com a cor selecionada dentro da área visível',
      (tester) async {
    const corSelecionada = Cor.laranja;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 250,
              child: SeletorDeCor(
                corSelecionada: corSelecionada,
                onCorSelecionada: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    final itemSelecionado = tester.getRect(
      find.byKey(const ValueKey('cor-laranja')),
    );

    expect(itemSelecionado.left, greaterThanOrEqualTo(viewport.left));
    expect(itemSelecionado.right, lessThanOrEqualTo(viewport.right));
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      greaterThan(0),
    );
  });

  testWidgets('não altera a rolagem ao selecionar outra cor manualmente', (
    tester,
  ) async {
    var corSelecionada = Cor.laranja;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 250,
              child: StatefulBuilder(
                builder: (context, atualizar) => SeletorDeCor(
                  corSelecionada: corSelecionada,
                  onCorSelecionada: (cor) {
                    atualizar(() => corSelecionada = cor);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final posicao =
        tester.state<ScrollableState>(find.byType(Scrollable)).position;
    posicao.jumpTo(100);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('cor-rosa')));
    await tester.pumpAndSettle();

    expect(corSelecionada, Cor.rosa);
    expect(posicao.pixels, 100);
  });
}
