import '../../compartilhamento/model/compartilhamento_model.dart';
import '../model/historico_com_itens_model.dart';
import '../repository/historico_repository.dart';

abstract interface class HistoricoServiceContract {
  Future<List<HistoricoComItens>> recuperarTodos();

  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  );
}

class HistoricoService implements HistoricoServiceContract {
  const HistoricoService(this._repository);

  final HistoricoRepository _repository;

  @override
  Future<List<HistoricoComItens>> recuperarTodos() =>
      _repository.recuperarTodosComItens();

  @override
  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  ) {
    return ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.historico,
      titulo: compra.historico.titulo,
      descricao: compra.historico.descricao,
      data: compra.historico.dataCompra,
      itens: compra.itens
          .map(
            (item) => ItemCompartilhamento(
              titulo: item.titulo,
              categoria: item.tituloCategoria,
              quantidade: item.quantidade,
              unidade: item.unidadeMedida,
              preco: item.preco,
              total: item.valorTotal,
            ),
          )
          .toList(growable: false),
    );
  }
}
