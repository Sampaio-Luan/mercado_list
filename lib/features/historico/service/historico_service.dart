import '../../compartilhamento/model/compartilhamento_model.dart';
import '../model/historico_com_itens_model.dart';
import '../repository/historico_repository.dart';
import '../model/historico_model.dart';
import '../model/item_historico_model.dart';

abstract interface class HistoricoServiceContract {
  Future<List<HistoricoComItens>> recuperarTodos();

  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  );

  Future<Historico> editar(Historico historico);

  Future<ItemHistorico> editarItem(ItemHistorico item);

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
    final descricao = historico.descricao?.trim();
    final loja = historico.loja?.trim();
    return _repository.editar(
      historico.copia(
        titulo: titulo,
        descricao: descricao,
        limparDescricao: descricao?.isEmpty ?? true,
        loja: loja,
        limparLoja: loja?.isEmpty ?? true,
      ),
    );
  }

  @override
  Future<void> excluir(Historico historico) => _repository.excluir(historico);

  @override
  Future<ItemHistorico> editarItem(ItemHistorico item) {
    final titulo = item.titulo.trim();
    if (titulo.isEmpty) throw ArgumentError('O título é obrigatório.');
    if (item.quantidade <= 0) {
      throw ArgumentError('A quantidade deve ser maior que zero.');
    }
    if (item.preco < 0) throw ArgumentError('O preço não pode ser negativo.');
    return _repository.editarItem(item.copia(titulo: titulo));
  }

  @override
  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  ) {
    return ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.historico,
      titulo: compra.historico.titulo,
      descricao: compra.historico.descricao,
      loja: compra.historico.loja,
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
