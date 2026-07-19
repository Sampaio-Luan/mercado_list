import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';

void main() {
  testWidgets('sem seleção toque abre menu e toque longo seleciona',
      (tester) async {
    var menusAbertos = 0;
    var selecoes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: InteracaoItemMenuSelecao(
          selecaoAtiva: false,
          aoAbrirMenu: () => menusAbertos++,
          aoAlternarSelecao: () => selecoes++,
          child: const Text('Item'),
        ),
      ),
    );

    await tester.tap(find.text('Item'));
    await tester.longPress(find.text('Item'));

    expect(menusAbertos, 1);
    expect(selecoes, 1);
  });

  testWidgets('com seleção toque seleciona e toque longo abre menu',
      (tester) async {
    var menusAbertos = 0;
    var selecoes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: InteracaoItemMenuSelecao(
          selecaoAtiva: true,
          aoAbrirMenu: () => menusAbertos++,
          aoAlternarSelecao: () => selecoes++,
          child: const Text('Item'),
        ),
      ),
    );

    await tester.tap(find.text('Item'));
    await tester.longPress(find.text('Item'));

    expect(selecoes, 1);
    expect(menusAbertos, 1);
  });
}
