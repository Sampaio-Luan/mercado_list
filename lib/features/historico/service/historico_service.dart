import '../../compartilhamento/model/compartilhamento_model.dart';
import '../model/historico_com_itens_model.dart';
import '../repository/historico_repository.dart';
import '../model/historico_model.dart';

abstract interface class HistoricoServiceContract {
  Future<List<HistoricoComItens>> recuperarTodos();

  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  );

  Future<Historico> editar(Historico historico);

  Future<void> excluir(Historico historico);
}

class HistoricoService implements HistoricoServiceContract {
  const HistoricoService(this._repository);

  final HistoricoRepositoryContract _repository;

  @override
  Future<List<HistoricoComItens>> recuperarTodos() =>
      _repository.recuperarTodosComItens();

  @override
  Future<Historico> editar(Historico historico) {
    final titulo = historico.titulo.trim();
    if (titulo.isEmpty) throw ArgumentError('O título é obrigatório.');
    return _repository.editar(
      historico.copia(
        titulo: titulo,
        descricao: historico.descricao?.trim(),
        limparDescricao: historico.descricao?.trim().isEmpty ?? true,
      ),
    );
  }

  @override
  Future<void> excluir(Historico historico) => _repository.excluir(historico);

  @override
  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  ) {
    return ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.historico,
      titulo: compra.historico.titulo,
      descricao: compra.historico.descricao,
      data: compra.historico.dataCompra,
      orcamento: compra.historico.orcamento,
      itens: compra.itens
          .map(
            (item) => ItemCompartilhamento(
              titulo: item.titulo,
              categoria: item.tituloCategoria,
              quantidade: item.quantidade,
              unidade: item.unidadeMedida,
              preco: item.preco,
              total: item.valorTotal,
              prioridade: switch (item.prioridade.name) {
                'baixa' => 'Baixa',
                'media' => 'Média',
                'alta' => 'Alta',
                _ => 'Neutra',
              },
              observacao: item.observacao,
            ),
          )
          .toList(growable: false),
    );
  }
}
