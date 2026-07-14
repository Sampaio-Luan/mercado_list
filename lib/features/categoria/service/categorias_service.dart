import 'dart:developer';

import '../../itens_recorrentes/model/item_recorrente_module.dart';
import '../../itens_recorrentes/repository/item_recorrente_repository.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';

class CategoriasService {
  final CategoriasRepository _categoriasRepository;
  final ItemRecorrenteRepository _itensRecorrentesRepository;
  List<CategoriaComItensRecorrentes> categoriasComItensRecorrentes = [];
  final _log = '🟡🏷️CategoriasService';

  CategoriasService({
    required this._categoriasRepository,
    required this._itensRecorrentesRepository,
  }) {
    _iniciaService();
  }

  void _iniciaService() async {
    List<Categoria> categorias = await _categoriasRepository.recuperarTodos();
    List<ItemRecorrente> itensRecorrentes = await _itensRecorrentesRepository
        .recuperarTodos();

    categoriasComItensRecorrentes = categorias
        .map(
          (categoria) => CategoriaComItensRecorrentes(
            categoria: categoria,
            itensRecorrentes: itensRecorrentes
                .where(
                  (itemRecorrente) =>
                      itemRecorrente.idCategoria == categoria.id,
                )
                .toList(),
          ),
        )
        .toList();

    log(
      name: _log,
      '_iniciaService(): categoriasComItensRecorrentes carregadas com sucesso. ${categoriasComItensRecorrentes.length} categorias',
    );
  }
}
