import 'dart:developer';

import '../../../core/constants/logs/logs.dart';
import '../../itens_recorrentes/model/item_recorrente_module.dart';
import '../../itens_recorrentes/repository/item_recorrente_repository.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';

class CategoriasService {
  final CategoriasRepository _categoriasRepository;
  final ItemRecorrenteRepository _itensRecorrentesRepository;
  final List<CategoriaComItensRecorrentes> _categoriasComItensRecorrentes = [];
  List<CategoriaComItensRecorrentes> get categoriasComItensRecorrentes =>
      List.unmodifiable(_categoriasComItensRecorrentes);

  CategoriasService({
    required this._categoriasRepository,
    required this._itensRecorrentesRepository,
  });

  Future<void> carregar() async {
    List<Categoria> categorias = await _categoriasRepository.recuperarTodos();
    List<ItemRecorrente> itensRecorrentes = await _itensRecorrentesRepository
        .recuperarTodos();

    _categoriasComItensRecorrentes
      ..clear()
      ..addAll(
        categorias.map(
          (categoria) => CategoriaComItensRecorrentes(
            categoria: categoria,
            itensRecorrentes: itensRecorrentes
                .where(
                  (itemRecorrente) =>
                      itemRecorrente.idCategoria == categoria.id,
                )
                .toList(),
          ),
        ),
      );

    log(
      name: LogId.categoriasService,
      '_iniciaService(): ${_categoriasComItensRecorrentes.length} categorias com itens recorrentes',
    );
  }

  Future<void> reordenar(int velhoIndex, int novoIndex) async {
    final item = _categoriasComItensRecorrentes.removeAt(velhoIndex);
    _categoriasComItensRecorrentes.insert(novoIndex, item);

    DateTime dataEdicao = DateTime.now();

    for (int i = 0; i < _categoriasComItensRecorrentes.length; i++) {
      _categoriasComItensRecorrentes[i].categoria.ordem = i + 1;
      _categoriasComItensRecorrentes[i].categoria.dtEdicao = dataEdicao;
    }

    List<Categoria> categorias = categoriasComItensRecorrentes
        .map((e) => e.categoria)
        .toList();
    log(
      name: LogId.categoriasService,
      'reordenar(): ${categorias.length} categorias reordenadas',
    );
    await _categoriasRepository.atualizarOrdens(categorias);
  }
}
