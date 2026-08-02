import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/historico/controller/historico_controller.dart';
import 'package:mercado_list/features/historico/model/filtro_historico.dart';
import 'package:mercado_list/features/historico/model/historico_com_itens_model.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/model/item_historico_model.dart';
import 'package:mercado_list/features/historico/service/historico_service.dart';

void main() {
  test('pesquisa em compras e itens e aplica ordenação', () async {
    final service = _HistoricoServiceFake([
      _compra(1, 'Farmácia', 'Sabonete', 1000, DateTime.now()),
      _compra(
        2,
        'Mercado',
        'Café',
        2500,
        DateTime.now().subtract(const Duration(days: 40)),
      ),
    ]);
    final controller = HistoricoController(service);
    await controller.carregar();

    controller.alterarPesquisa('cafe');
    expect(controller.comprasVisiveis.single.historico.titulo, 'Mercado');

    controller.alterarPesquisa('');
    controller.alterarPeriodo(PeriodoHistorico.trintaDias);
    expect(controller.comprasVisiveis.single.historico.titulo, 'Farmácia');

    controller.alterarPeriodo(PeriodoHistorico.todos);
    controller.alterarOrdenacao(OrdenacaoHistorico.maiorValor);
    expect(controller.comprasVisiveis.first.historico.titulo, 'Mercado');
  });

  test('edita e exclui mantendo o estado em memória', () async {
    final compra = _compra(1, 'Mercado', 'Arroz', 1000, DateTime.now());
    final service = _HistoricoServiceFake([compra]);
    final controller = HistoricoController(service);
    await controller.carregar();

    await controller.editar(
      compra,
      compra.historico.copia(titulo: 'Compra editada'),
    );
    expect(controller.compras.single.historico.titulo, 'Compra editada');

    await controller.excluir(controller.compras.single);
    expect(controller.compras, isEmpty);
  });
}

HistoricoComItens _compra(
  int id,
  String titulo,
  String item,
  int preco,
  DateTime data,
) =>
    HistoricoComItens(
      historico: Historico(id: id, titulo: titulo, dataCompra: data),
      itens: [
        ItemHistorico(
          idHistorico: id,
          titulo: item,
          tituloCategoria: 'Geral',
          quantidade: 1,
          preco: preco,
          unidadeMedida: 'und',
        ),
      ],
    );

class _HistoricoServiceFake implements HistoricoServiceContract {
  _HistoricoServiceFake(this.compras);

  final List<HistoricoComItens> compras;

  @override
  Future<List<HistoricoComItens>> recuperarTodos() async => compras;

  @override
  Future<Historico> editar(Historico historico) async => historico;

  @override
  Future<void> excluir(Historico historico) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
