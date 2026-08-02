import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/prioridade.dart';
import 'package:mercado_list/features/historico/model/historico_com_itens_model.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/model/item_historico_model.dart';
import 'package:mercado_list/features/historico/repository/historico_repository.dart';
import 'package:mercado_list/features/historico/service/historico_service.dart';

void main() {
  test('prepara compartilhamento com snapshot completo', () {
    final service = HistoricoService(_HistoricoRepositoryFake());
    final compra = _compra();

    final conteudo = service.prepararCompartilhamento(compra);

    expect(conteudo.titulo, 'Compra mensal');
    expect(conteudo.orcamento, 50000);
    expect(conteudo.itens.single.prioridade, 'Alta');
    expect(conteudo.itens.single.observacao, 'Integral');
    expect(conteudo.itens.single.total, 2500);
  });

  test('edição normaliza dados antes de persistir', () async {
    final repository = _HistoricoRepositoryFake();
    final service = HistoricoService(repository);
    final historico = _compra().historico.copia(
          titulo: '  Compra editada  ',
          descricao: '  descrição  ',
        );

    final editado = await service.editar(historico);

    expect(editado.titulo, 'Compra editada');
    expect(editado.descricao, 'descrição');
    expect(repository.editado, isNotNull);
  });

  test('edição rejeita título vazio', () async {
    final repository = _HistoricoRepositoryFake();
    final service = HistoricoService(repository);

    expect(
      () => service.editar(_compra().historico.copia(titulo: '   ')),
      throwsArgumentError,
    );

    expect(repository.editado, isNull);
  });
}

HistoricoComItens _compra() => HistoricoComItens(
      historico: Historico(
        id: 1,
        titulo: 'Compra mensal',
        descricao: 'Casa',
        dataCompra: DateTime.utc(2026, 8, 2),
        cor: Colors.indigo,
        orcamento: 50000,
      ),
      itens: [
        ItemHistorico(
          id: 1,
          idHistorico: 1,
          titulo: 'Leite',
          tituloCategoria: 'Laticínios',
          quantidade: 2,
          preco: 1250,
          unidadeMedida: 'und',
          prioridade: Prioridade.alta,
          observacao: 'Integral',
        ),
      ],
    );

class _HistoricoRepositoryFake implements HistoricoRepositoryContract {
  Historico? editado;

  @override
  Future<Historico> editar(Historico historico) async {
    editado = historico;
    return historico;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
