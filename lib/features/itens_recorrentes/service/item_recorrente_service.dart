import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../model/item_recorrente_model.dart';
import '../repository/item_recorrente_repository.dart';

class ItemRecorrenteService {
  final ItemRecorrenteRepository _repository;

  ItemRecorrenteService(this._repository);

  Future<ItemRecorrente> criar(ItemRecorrente item) async {
    _registrarInicio(
      'criar',
      'categoria=${item.idCategoria}, titulo=${item.titulo}',
    );
    try {
      _validarItem(item, exigirPersistido: false);
      final itemCriado = await _repository.criar(item);
      _registrarSucesso(
        'criar',
        'item=${itemCriado.id}, categoria=${itemCriado.idCategoria}',
      );
      return itemCriado;
    } catch (erro, stackTrace) {
      _registrarErro('criar', erro, stackTrace);
      rethrow;
    }
  }

  Future<ItemRecorrente> editar(ItemRecorrente item) async {
    _registrarInicio('editar', 'item=${item.id}');
    try {
      _validarItem(item, exigirPersistido: true);
      final itemEditado = await _repository.editar(item);
      _registrarSucesso('editar', 'item=${itemEditado.id}');
      return itemEditado;
    } catch (erro, stackTrace) {
      _registrarErro('editar', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluir(int id) async {
    _registrarInicio('excluir', 'item=$id');
    try {
      if (id <= 0) {
        throw ArgumentError.value(id, 'id', 'O id deve ser maior que zero.');
      }
      await _repository.excluir(id);
      _registrarSucesso('excluir', 'item=$id');
    } catch (erro, stackTrace) {
      _registrarErro('excluir', erro, stackTrace);
      rethrow;
    }
  }

  Future<List<ItemRecorrente>> recuperarTodos() async {
    _registrarInicio('recuperarTodos', 'buscando itens ativos');
    try {
      final itens = await _repository.recuperarTodos();
      _registrarSucesso('recuperarTodos', 'quantidade=${itens.length}');
      return itens;
    } catch (erro, stackTrace) {
      _registrarErro('recuperarTodos', erro, stackTrace);
      rethrow;
    }
  }

  Future<List<ItemRecorrente>> buscarPorCategoria({
    required int idCategoria,
    DatabaseExecutor? databaseExecutor,
  }) async {
    _registrarInicio('buscarPorCategoria', 'categoria=$idCategoria');
    try {
      _validarIdCategoria(idCategoria);
      final itens = await _repository.buscarPorCategoria(
        idCategoria,
        databaseExecutor: databaseExecutor,
      );
      _registrarSucesso(
        'buscarPorCategoria',
        'categoria=$idCategoria, quantidade=${itens.length}',
      );
      return itens;
    } catch (erro, stackTrace) {
      _registrarErro('buscarPorCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> moverParaCategoria({
    required List<ItemRecorrente> itens,
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    _registrarInicio(
      'moverParaCategoria',
      'origem=$categoriaOrigem, destino=$categoriaDestino, '
          'quantidade=${itens.length}',
    );
    try {
      _validarMovimentacao(
        itens: itens,
        categoriaOrigem: categoriaOrigem,
        categoriaDestino: categoriaDestino,
      );

      final quantidadeAtualizada = await _repository.atualizarCategoriaDosItens(
        categoriaOrigem: categoriaOrigem,
        categoriaDestino: categoriaDestino,
        databaseExecutor: databaseExecutor,
        dataAlteracao: dataAlteracao,
      );

      if (quantidadeAtualizada != itens.length) {
        throw StateError(
          'Não foi possível mover todos os itens recorrentes: '
          '${itens.length} esperados e $quantidadeAtualizada atualizados.',
        );
      }

      _registrarSucesso(
        'moverParaCategoria',
        'origem=$categoriaOrigem, destino=$categoriaDestino, '
            'quantidade=$quantidadeAtualizada',
      );
    } catch (erro, stackTrace) {
      _registrarErro('moverParaCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<ItemRecorrente> moverItemParaCategoria({
    required ItemRecorrente item,
    required int idCategoriaDestino,
  }) async {
    _registrarInicio(
      'moverItemParaCategoria',
      'item=${item.id}, origem=${item.idCategoria}, '
          'destino=$idCategoriaDestino',
    );
    try {
      _validarItem(item, exigirPersistido: true);
      _validarIdCategoria(idCategoriaDestino);
      if (item.idCategoria == idCategoriaDestino) {
        throw ArgumentError('O item já pertence à categoria de destino.');
      }
      final itemMovido = await _repository.moverItemParaCategoria(
        idItem: item.id!,
        categoriaOrigem: item.idCategoria,
        categoriaDestino: idCategoriaDestino,
      );
      _registrarSucesso(
        'moverItemParaCategoria',
        'item=${itemMovido.id}, destino=$idCategoriaDestino',
      );
      return itemMovido;
    } catch (erro, stackTrace) {
      _registrarErro('moverItemParaCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<List<ItemRecorrente>> moverItensParaCategoria({
    required List<ItemRecorrente> itens,
    required int idCategoriaDestino,
  }) async {
    _registrarInicio(
      'moverItensParaCategoria',
      'destino=$idCategoriaDestino, quantidade=${itens.length}',
    );
    try {
      if (itens.isEmpty) {
        throw ArgumentError('Selecione ao menos um item para mover.');
      }
      _validarIdCategoria(idCategoriaDestino);
      for (final item in itens) {
        _validarItem(item, exigirPersistido: true);
      }

      final categoriaOrigem = itens.first.idCategoria;
      if (categoriaOrigem == idCategoriaDestino) {
        throw ArgumentError('Os itens já pertencem à categoria de destino.');
      }
      if (itens.any((item) => item.idCategoria != categoriaOrigem)) {
        throw ArgumentError(
          'Todos os itens devem pertencer à mesma categoria de origem.',
        );
      }

      final idsItens = itens.map((item) => item.id!).toSet().toList();
      if (idsItens.length != itens.length) {
        throw ArgumentError('A seleção contém itens duplicados.');
      }

      final itensMovidos = await _repository.moverItensParaCategoria(
        idsItens: idsItens,
        categoriaOrigem: categoriaOrigem,
        categoriaDestino: idCategoriaDestino,
      );
      _registrarSucesso(
        'moverItensParaCategoria',
        'origem=$categoriaOrigem, destino=$idCategoriaDestino, '
            'quantidade=${itensMovidos.length}',
      );
      return itensMovidos;
    } catch (erro, stackTrace) {
      _registrarErro('moverItensParaCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluirItens(List<ItemRecorrente> itens) async {
    _registrarInicio('excluirItens', 'quantidade=${itens.length}');
    try {
      if (itens.isEmpty) {
        throw ArgumentError('Selecione ao menos um item para excluir.');
      }
      for (final item in itens) {
        _validarItem(item, exigirPersistido: true);
      }
      final idsItens = itens.map((item) => item.id!).toSet().toList();
      if (idsItens.length != itens.length) {
        throw ArgumentError('A seleção contém itens duplicados.');
      }
      await _repository.excluirItens(idsItens);
      _registrarSucesso('excluirItens', 'quantidade=${itens.length}');
    } catch (erro, stackTrace) {
      _registrarErro('excluirItens', erro, stackTrace);
      rethrow;
    }
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

  void _validarItem(
    ItemRecorrente item, {
    required bool exigirPersistido,
  }) {
    _validarIdCategoria(item.idCategoria);
    if (item.titulo.trim().isEmpty) {
      throw ArgumentError.value(
        item.titulo,
        'titulo',
        'O título do item é obrigatório.',
      );
    }
    if (exigirPersistido && (item.id == null || item.id! <= 0)) {
      throw StateError('O item precisa estar persistido.');
    }
    if (!exigirPersistido && item.id != null) {
      throw StateError('Um novo item ainda não pode possuir id.');
    }
  }

  void _registrarInicio(String operacao, String detalhes) {
    log(
      '$operacao(): iniciando; $detalhes',
      name: LogId.itensRecorrentesService,
    );
  }

  void _registrarSucesso(String operacao, String detalhes) {
    log(
      '$operacao(): concluído com sucesso; $detalhes',
      name: LogId.itensRecorrentesService,
    );
  }

  void _registrarErro(
    String operacao,
    Object erro,
    StackTrace stackTrace,
  ) {
    log(
      '$operacao(): $erro',
      name: LogId.itensRecorrentesService,
      error: erro,
      stackTrace: stackTrace,
    );
  }
}
