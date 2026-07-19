import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/widget/item_recorrente_painel_widget.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

void main() {
  testWidgets('item selecionado apresenta feedback visual', (tester) async {
    final item = ItemRecorrente(
      id: 1,
      idCategoria: 2,
      titulo: 'Arroz',
      tipoMedida: TipoMedida.und,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(surface: Colors.white),
        ),
        home: Scaffold(
          body: ItemRecorrentePainelWidget(
            item: item,
            termoPesquisa: '',
            corCategoria: Colors.orange,
            selecionado: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(PhosphorIcons.check), findsOneWidget);
    final card = tester.widget<Card>(find.byType(Card));
    expect(
      card.color,
      Color.alphaBlend(Colors.orange.withAlpha(15), Colors.white),
    );
  });
}
