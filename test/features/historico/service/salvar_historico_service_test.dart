import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/model/progresso_operacao.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/repository/historico_repository.dart';
import 'package:mercado_list/features/historico/service/salvar_historico_service.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';

void main() {
  test('salva somente itens marcados com preço e informa o progresso',
      () async {
    final repository = _HistoricoRepositoryFake();
    final service = SalvarHistoricoService(repository);
    final progressos = <ProgressoOperacao>[];

    final salvo = await service.executar(
      historico: Historico(
        titulo: '  Compra mensal  ',
        loja: '  Mercado Central  ',
        dataCompra: DateTime.utc(2026, 8, 2),
        cor: Colors.indigo,
      ),
      itens: [
        _item('Arroz', marcado: true, preco: 1000),
        _item('Feijão', marcado: true),
        _item('Café', marcado: false, preco: 1500),
      ],
      titulosCategorias: const {1: 'Mercearia'},
      aoProgredir: progressos.add,
    );

    expect(repository.itensSalvos.map((item) => item.titulo), ['Arroz']);
    expect(repository.historicoSalvo?.titulo, 'Compra mensal');
    expect(repository.historicoSalvo?.loja, 'Mercado Central');
    expect(salvo.id, 10);
    expect(progressos.map((progresso) => progresso.etapa), [1, 2, 3, 4, 5]);
    expect(progressos[3].descricao, 'Salvando item 1 de 1: Arroz');
  });

  test('rejeita salvamento quando nenhum item marcado possui preço', () {
    final repository = _HistoricoRepositoryFake();
    final service = SalvarHistoricoService(repository);

    expect(
      () => service.executar(
        historico: Historico(
          titulo: 'Compra',
          dataCompra: DateTime.utc(2026, 8, 2),
        ),
        itens: [_item('Arroz', marcado: true)],
        titulosCategorias: const {1: 'Mercearia'},
      ),
      throwsStateError,
    );
    expect(repository.historicoSalvo, isNull);
  });
}

Item _item(String titulo, {required bool marcado, int? preco}) => Item(
      idLista: 1,
      idCategoria: 1,
      titulo: titulo,
      tipoMedida: TipoMedida.und,
      quantidade: 1,
      preco: preco,
      obtido: marcado,
    );

class _HistoricoRepositoryFake implements HistoricoRepositoryContract {
  Historico? historicoSalvo;
  List<Item> itensSalvos = [];

  @override
  Future<Historico> salvarCompra({
    required Historico historico,
    required List<Item> itens,
    required Map<int, String> titulosCategorias,
    AoSalvarItemHistorico? aoSalvarItem,
  }) async {
    historicoSalvo = historico;
    itensSalvos = itens;
    for (var indice = 0; indice < itens.length; indice++) {
      await aoSalvarItem?.call(indice + 1, itens.length, itens[indice].titulo);
    }
    return Historico(
      id: 10,
      titulo: historico.titulo,
      descricao: historico.descricao,
      loja: historico.loja,
      dataCompra: historico.dataCompra,
      cor: historico.cor,
      orcamento: historico.orcamento,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
