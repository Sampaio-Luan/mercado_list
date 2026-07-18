import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/card_progresso_operacao.dart';

void main() {
  testWidgets('apresenta título, etapa, descrição e progresso', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CardProgressoOperacao(
            titulo: 'Exportando dados',
            descricao: 'Gerando arquivo CSV...',
            etapaAtual: 2,
            totalEtapas: 5,
            estado: EstadoProgressoOperacao.processando,
          ),
        ),
      ),
    );

    expect(find.text('Exportando dados'), findsOneWidget);
    expect(find.text('Gerando arquivo CSV...'), findsOneWidget);
    expect(find.text('2/5'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('permite fechar o card quando a operação falha', (tester) async {
    var fechou = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardProgressoOperacao(
            titulo: 'Importando dados',
            descricao: 'Não foi possível importar o arquivo.',
            etapaAtual: 3,
            totalEtapas: 4,
            estado: EstadoProgressoOperacao.erro,
            onFechar: () => fechou = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Fechar'));

    expect(fechou, isTrue);
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
  });
}
