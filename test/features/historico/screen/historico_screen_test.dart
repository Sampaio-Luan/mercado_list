import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/compartilhamento/service/compartilhamento_service.dart';
import 'package:mercado_list/features/historico/controller/historico_controller.dart';
import 'package:mercado_list/features/historico/form/historico_formulario.dart';
import 'package:mercado_list/features/historico/model/historico_com_itens_model.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/model/item_historico_model.dart';
import 'package:mercado_list/features/historico/screen/historico_screen.dart';
import 'package:mercado_list/features/historico/service/historico_service.dart';
import 'package:mercado_list/features/historico/widget/barra_historico.dart';
import 'package:mercado_list/features/historico/widget/historico_detalhes_sheet.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('exibe filtros, detalhes e formulário de edição', (tester) async {
    final controller = HistoricoController(_HistoricoServiceFake());
    await controller.carregar();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
          Provider.value(value: CompartilhamentoService()),
        ],
        child: const MaterialApp(home: HistoricoScreen()),
      ),
    );

    expect(find.byType(BarraHistorico), findsOneWidget);
    expect(find.text('Compra mensal'), findsOneWidget);

    await tester.tap(find.text('Compra mensal'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoricoDetalhesSheet), findsOneWidget);
    expect(find.text('Mercearia'), findsOneWidget);
    expect(find.text('Arroz (N)'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoricoFormulario), findsOneWidget);
    expect(find.text('Editar compra'), findsOneWidget);
    expect(find.text('Data da compra'), findsOneWidget);
    expect(find.text('Orçamento (opcional)'), findsOneWidget);
  });
}

class _HistoricoServiceFake implements HistoricoServiceContract {
  final compra = HistoricoComItens(
    historico: Historico(
      id: 1,
      titulo: 'Compra mensal',
      dataCompra: DateTime.utc(2026, 8, 2),
      cor: Colors.indigo,
      orcamento: 50000,
    ),
    itens: [
      ItemHistorico(
        idHistorico: 1,
        titulo: 'Arroz',
        tituloCategoria: 'Mercearia',
        quantidade: 1,
        preco: 1000,
        unidadeMedida: 'und',
      ),
    ],
  );

  @override
  Future<List<HistoricoComItens>> recuperarTodos() async => [compra];

  @override
  Future<Historico> editar(Historico historico) async => historico;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
