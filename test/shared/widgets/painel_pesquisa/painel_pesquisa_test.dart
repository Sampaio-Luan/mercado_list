import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';

void main() {
  testWidgets('renderer customizado recebe item e termo após a filtragem',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PainelPesquisa<String>(
            itens: const ['Arroz', 'Feijão'],
            obterTextoPesquisa: (item) => item,
            modoSelecao: ModoInteracaoPainel.semSelecao,
            construirItem: (_, resultado) => Text(
              '${resultado.item}|${resultado.termoPesquisa}',
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Arroz');
    await tester.pump();

    expect(find.text('Arroz|Arroz'), findsOneWidget);
    expect(find.textContaining('Feijão|'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('painel modal possui ScaffoldMessenger acima da página',
      (tester) async {
    late BuildContext contextoPagina;
    late BuildContext contextoItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              contextoPagina = context;
              return ElevatedButton(
                onPressed: () {
                  PainelPesquisa.exibir<String>(
                    context: context,
                    itens: const ['Arroz'],
                    obterTextoPesquisa: (item) => item,
                    modoSelecao: ModoInteracaoPainel.semSelecao,
                    construirItem: (context, resultado) {
                      contextoItem = context;
                      return Text(resultado.item);
                    },
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(
      ScaffoldMessenger.of(contextoItem),
      isNot(same(ScaffoldMessenger.of(contextoPagina))),
    );

    Navigator.of(contextoItem).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('seleção única funciona com item customizado', (tester) async {
    Object? resultado;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                resultado = await PainelPesquisa.exibir<String>(
                  context: context,
                  itens: const ['Arroz', 'Feijão'],
                  obterTextoPesquisa: (item) => item,
                  modoSelecao: ModoInteracaoPainel.unica,
                  construirItem: (_, item) => Text(item.item),
                );
              },
              child: const Text('Abrir seleção única'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir seleção única'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feijão'));
    await tester.pumpAndSettle();

    expect(resultado, 'Feijão');
    expect(find.byType(PainelPesquisa<String>), findsNothing);
  });

  testWidgets('seleção múltipla funciona com itens customizados',
      (tester) async {
    Object? resultado;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                resultado = await PainelPesquisa.exibir<String>(
                  context: context,
                  itens: const ['Arroz', 'Feijão'],
                  obterTextoPesquisa: (item) => item,
                  modoSelecao: ModoInteracaoPainel.multipla,
                  construirItem: (_, item) => Text(item.item),
                );
              },
              child: const Text('Abrir seleção múltipla'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir seleção múltipla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arroz'));
    await tester.pump();
    await tester.tap(find.text('Feijão'));
    await tester.pump();
    await tester.tap(find.text('Confirmar seleção (2)'));
    await tester.pumpAndSettle();

    expect(resultado, ['Arroz', 'Feijão']);
    expect(find.byType(PainelPesquisa<String>), findsNothing);
  });

  testWidgets('toque fora do painel fecha o modal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                PainelPesquisa.exibir<String>(
                  context: context,
                  itens: const ['Arroz'],
                  obterTextoPesquisa: (item) => item,
                );
              },
              child: const Text('Abrir painel'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir painel'));
    await tester.pumpAndSettle();
    expect(find.byType(PainelPesquisa<String>), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(PainelPesquisa<String>), findsNothing);
  });

  testWidgets('painel imperativo ignora toque fora e fecha pelo botão',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                PainelPesquisa.exibir<String>(
                  context: context,
                  itens: const ['Arroz'],
                  obterTextoPesquisa: (item) => item,
                  fecharAoTocarFora: false,
                  fecharAoArrastar: false,
                );
              },
              child: const Text('Abrir painel imperativo'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir painel imperativo'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(PainelPesquisa<String>), findsOneWidget);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(PainelPesquisa<String>), findsNothing);
  });

  testWidgets('teclado expande painel e preserva o rodapé', (tester) async {
    Widget construir(double alturaTeclado) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(800, 600),
            viewInsets: EdgeInsets.only(bottom: alturaTeclado),
          ),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: PainelPesquisa<String>(
              itens: const ['Arroz', 'Feijão'],
              obterTextoPesquisa: (item) => item,
              construirRodape: (_, _) => const SizedBox(
                height: 72,
                child: Center(child: Text('Adicionar item recorrente')),
              ),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(construir(0));
    await tester.pumpWidget(construir(300));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar item recorrente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
