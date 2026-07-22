import '../../../core/contracts/gerenciador_transacoes.dart';
import '../../../core/utils/texto_utils.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/repository/item_recorrente_repository.dart';
import '../model/item_model.dart';
import '../repository/itens_repository.dart';

class CriarItemService {
  final GerenciadorTransacoes _transacoes;
  final ItensRepository _itensRepository;
  final ItemRecorrenteRepository _recorrentesRepository;

  CriarItemService(
    this._transacoes,
    this._itensRepository,
    this._recorrentesRepository,
  );

  Future<Item> executar({
    required Item item,
    required Iterable<ItemRecorrente> recorrentesExistentes,
  }) {
    item.titulo = item.titulo.trim();
    if (item.titulo.isEmpty) {
      throw ArgumentError('O título do item é obrigatório.');
    }
    if (item.idLista <= 0 || item.idCategoria <= 0) {
      throw ArgumentError('A lista e a categoria são obrigatórias.');
    }
    return _transacoes.executar((executor) async {
      final criado = await _itensRepository.criar(
        item,
        databaseExecutor: executor,
      );
      final titulo = TextoUtils.normalizarParaOrdenacao(item.titulo);
      final existe = recorrentesExistentes.any((recorrente) =>
          recorrente.idCategoria == item.idCategoria &&
          recorrente.tipoMedida == item.tipoMedida &&
          TextoUtils.normalizarParaOrdenacao(recorrente.titulo) == titulo);
      if (!existe) {
        await _recorrentesRepository.criar(
          ItemRecorrente(
            idCategoria: item.idCategoria,
            titulo: item.titulo,
            tipoMedida: item.tipoMedida,
          ),
          databaseExecutor: executor,
        );
      }
      return criado;
    });
  }
}
