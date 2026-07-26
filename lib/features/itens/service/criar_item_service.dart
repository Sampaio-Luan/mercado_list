import '../../../core/contracts/gerenciador_transacoes.dart';
import '../../../core/utils/texto_utils.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/repository/item_recorrente_repository.dart';
import '../model/item_model.dart';
import '../repository/itens_repository.dart';

class CriarItemService {
  final GerenciadorTransacoes _transacoes;
  final ItensRepositoryContract _itensRepository;
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
    final novo = item.copia(titulo: item.titulo.trim());
    if (novo.titulo.isEmpty) {
      throw ArgumentError('O título do item é obrigatório.');
    }
    if (novo.idLista <= 0) {
      throw ArgumentError('A lista é obrigatória.');
    }
    if (novo.quantidade != null && novo.quantidade! <= 0) {
      throw ArgumentError('A quantidade deve ser positiva.');
    }
    if (novo.preco != null && novo.preco! < 0) {
      throw ArgumentError('O preço não pode ser negativo.');
    }
    return _transacoes.executar((executor) async {
      if (novo.idCategoria <= 0) {
        novo.idCategoria = await _itensRepository.buscarIdCategoriaPadrao();
      }
      final criado = await _itensRepository.criar(
        novo,
        databaseExecutor: executor,
      );
      final titulo = TextoUtils.normalizarParaOrdenacao(novo.titulo);
      final existe = recorrentesExistentes.any((recorrente) =>
          recorrente.idCategoria == novo.idCategoria &&
          recorrente.tipoMedida == novo.tipoMedida &&
          TextoUtils.normalizarParaOrdenacao(recorrente.titulo) == titulo);
      if (!existe) {
        await _recorrentesRepository.criar(
          ItemRecorrente(
            idCategoria: novo.idCategoria,
            titulo: novo.titulo,
            tipoMedida: novo.tipoMedida,
          ),
          databaseExecutor: executor,
        );
      }
      return criado;
    });
  }
}
