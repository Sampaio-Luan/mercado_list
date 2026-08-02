import '../../itens/model/item_model.dart';
import '../../listas/model/lista_model.dart';
import '../model/historico_model.dart';
import '../repository/historico_repository.dart';

abstract interface class SalvarHistoricoServiceContract {
  Future<Historico> executar({
    required Lista lista,
    required Iterable<Item> itens,
    required Map<int, String> titulosCategorias,
  });
}

class SalvarHistoricoService implements SalvarHistoricoServiceContract {
  final HistoricoRepository _repository;

  SalvarHistoricoService(this._repository);

  @override
  Future<Historico> executar({
    required Lista lista,
    required Iterable<Item> itens,
    required Map<int, String> titulosCategorias,
  }) {
    final marcados = itens.where((item) => item.obtido).toList();
    if (marcados.isEmpty) {
      throw StateError('Marque ao menos um item antes de salvar no histórico.');
    }
    return _repository.salvarCompra(
      lista: lista,
      itens: marcados,
      titulosCategorias: titulosCategorias,
    );
  }
}
