import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/extensions/cor_contraste_extension.dart';
import 'package:mercado_list/features/compartilhamento/model/compartilhamento_model.dart';
import 'package:mercado_list/features/compartilhamento/service/compartilhamento_service.dart';
import 'package:mercado_list/features/compartilhamento/widget/compartilhamento_sheet.dart';

void main() {
  testWidgets('oferece texto e colore todos os ícones de formato', (
    tester,
  ) async {
    const corDestaque = Colors.indigo;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompartilhamentoSheet(
            conteudo: const ConteudoCompartilhamento(
              contexto: ContextoCompartilhamento.lista,
              titulo: 'Mercado',
              itens: [
                ItemCompartilhamento(titulo: 'Arroz', marcado: false),
              ],
            ),
            corDestaque: corDestaque,
            service: CompartilhamentoService(),
          ),
        ),
      ),
    );
    final contexto = tester.element(find.byType(CompartilhamentoSheet));
    final corEsperada = corDestaque.paraPrimeiroPlano(Theme.of(contexto));

    expect(find.text('Texto'), findsOneWidget);
    for (final icone in [
      Icons.notes_outlined,
      Icons.image_outlined,
      Icons.picture_as_pdf_outlined,
      Icons.table_rows_outlined,
      Icons.grid_on_outlined,
      Icons.data_object,
    ]) {
      expect(tester.widget<Icon>(find.byIcon(icone)).color, corEsperada);
    }
    expect(
      tester.widget<Icon>(find.byIcon(Icons.lock_outline)).color,
      corEsperada,
    );
  });
}
