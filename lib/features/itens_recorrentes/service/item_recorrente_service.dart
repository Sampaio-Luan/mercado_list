import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../model/item_recorrente_model.dart';
import '../repository/item_recorrente_repository.dart';

class ItemRecorrenteService {
  final ItemRecorrenteRepository _repository;

  ItemRecorrenteService(this._repository);

  Future<List<ItemRecorrente>> recuperarTodos() {
    return _repository.recuperarTodos();
  }

  Future<List<ItemRecorrente>> buscarPorCategoria({
    required int idCategoria,
    DatabaseExecutor? databaseExecutor,
  }) {
    _validarIdCategoria(idCategoria);
    return _repository.buscarPorCategoria(
      idCategoria,
      databaseExecutor: databaseExecutor,
    );
  }

  Future<void> moverParaCategoria({
    required List<ItemRecorrente> itens,
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) async {
    _validarMovimentacao(
      itens: itens,
      categoriaOrigem: categoriaOrigem,
      categoriaDestino: categoriaDestino,
    );

    final quantidadeAtualizada = await _repository.atualizarCategoriaDosItens(
      categoriaOrigem: categoriaOrigem,
      categoriaDestino: categoriaDestino,
      databaseExecutor: databaseExecutor,
    );

    if (quantidadeAtualizada != itens.length) {
      throw StateError(
        'Não foi possível mover todos os itens recorrentes: '
        '${itens.length} esperados e $quantidadeAtualizada atualizados.',
      );
    }

    log(
      name: LogId.itensRecorrentesService,
      'moverParaCategoria(): $quantidadeAtualizada itens movidos.',
    );
  }

  void _validarMovimentacao({
    required List<ItemRecorrente> itens,
    required int categoriaOrigem,
    required int categoriaDestino,
  }) {
    _validarIdCategoria(categoriaOrigem);
    _validarIdCategoria(categoriaDestino);

    if (categoriaOrigem == categoriaDestino) {
      throw ArgumentError(
          'As categorias de origem e destino devem ser diferentes.');
    }
    if (itens.any((item) => item.idCategoria != categoriaOrigem)) {
      throw ArgumentError(
        'Todos os itens devem pertencer à categoria de origem.',
      );
    }
  }

  void _validarIdCategoria(int idCategoria) {
    if (idCategoria <= 0) {
      throw ArgumentError.value(
        idCategoria,
        'idCategoria',
        'O id da categoria deve ser maior que zero.',
      );
    }
  }
}
