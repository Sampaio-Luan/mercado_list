import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/menu_contexto/menu_contexto_exportacoes.dart';

void main() {
  testWidgets('fecha o menu antes de executar a ação assíncrona',
      (tester) async {
    var executou = false;
    late BuildContext contextoBase;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              contextoBase = context;
              return MenuDeContexto(
                acoes: [
                  AcaoMenuContexto(
                    titulo: 'Editar',
                    aoSelecionar: () async {
                      executou = true;
                      await showDialog<void>(
                        context: contextoBase,
                        builder: (_) => const AlertDialog(
                          content: Text('Formulário de edição'),
                        ),
                      );
                    },
                  ),
                ],
                child: const Text('Abrir menu'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir menu'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(executou, isTrue);
    expect(find.text('Editar'), findsNothing);
    expect(find.text('Formulário de edição'), findsOneWidget);
  });
}
