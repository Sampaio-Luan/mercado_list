import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/utils/data_utils.dart';
import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';

abstract interface class CategoriasServiceContract {
  Future<Categoria> criar(Categoria categoria);

  Future<Categoria> editar(Categoria categoria);

  Future<List<Categoria>> recuperarTodos();

  Future<Categoria> prepararExclusao(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
  });

  Future<void> excluir(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  });

  Future<void> atualizarOrdens(List<Categoria> categorias);
}

class CategoriasService implements CategoriasServiceContract {
  final CategoriasRepository _repository;

  CategoriasService(this._repository);

  @override
  Future<Categoria> criar(Categoria categoria) async {
    log(
      'criar(): iniciando; titulo=${categoria.titulo}',
      name: LogId.categoriasService,
    );
    try {
      if (categoria.id != null) {
        throw StateError('Uma nova categoria ainda não pode possuir id.');
      }
      categoria.titulo = categoria.titulo.trim();
      if (categoria.titulo.isEmpty) {
        throw ArgumentError('O título da categoria é obrigatório.');
      }
      final categoriaCriada = await _repository.criar(categoria);
      log(
        'criar(): concluído com sucesso; categoria=${categoriaCriada.id}',
        name: LogId.categoriasService,
      );
      return categoriaCriada;
    } catch (erro, stackTrace) {
      log(
        'criar(): $erro',
        name: LogId.categoriasService,
        error: erro,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Categoria> editar(Categoria categoria) async {
    log(
      'editar(): iniciando; categoria=${categoria.id}',
      name: LogId.categoriasService,
    );
    try {
      if (categoria.id == null || categoria.id! <= 0) {
        throw StateError(
            'A categoria precisa estar persistida para ser editada.');
      }

      final categoriaPersistida = await _repository.recuperar(categoria.id!);
      final titulo = categoria.titulo.trim();
      if (titulo.isEmpty) {
        throw ArgumentError('O título da categoria é obrigatório.');
      }
      if (categoriaPersistida.categoriaPadrao &&
          titulo != categoriaPersistida.titulo) {
        throw StateError('O título da categoria padrão não pode ser alterado.');
      }
      if (categoria.categoriaPadrao != categoriaPersistida.categoriaPadrao) {
        throw StateError('O tipo da categoria não pode ser alterado.');
      }

      categoria
        ..titulo = titulo
        ..ordem = categoriaPersistida.ordem
        ..categoriaPadrao = categoriaPersistida.categoriaPadrao
        ..excluido = categoriaPersistida.excluido
        ..dataCriacao = categoriaPersistida.dataCriacao;

      final categoriaEditada = await _repository.editar(categoria);
      log(
        'editar(): concluído com sucesso; categoria=${categoriaEditada.id}',
        name: LogId.categoriasService,
      );
      return categoriaEditada;
    } catch (erro, stackTrace) {
      log(
        'editar(): $erro',
        name: LogId.categoriasService,
        error: erro,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<Categoria>> recuperarTodos() {
    return _repository.recuperarTodos();
  }

  @override
  Future<Categoria> prepararExclusao(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    _validarCategoriaParaExclusao(categoria);
    final categoriaPadrao = await _repository.buscarCategoriaPadrao(
      databaseExecutor: databaseExecutor,
    );

    if (categoria.id == categoriaPadrao.id) {
      throw StateError('A categoria padrão não pode ser excluída.');
    }
    return categoriaPadrao;
  }

  @override
  Future<void> excluir(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    _validarCategoriaParaExclusao(categoria);
    await _repository.excluir(
      categoria.id!,
      databaseExecutor: databaseExecutor,
      dataAlteracao: dataAlteracao,
    );
  }

  @override
  Future<void> atualizarOrdens(List<Categoria> categorias) async {
    if (categorias.any((categoria) => categoria.id == null)) {
      throw StateError('Todas as categorias devem estar persistidas.');
    }
    final agora = DataUtils.agoraUtc();
    await _repository.atualizarOrdens(
      categorias,
      dataAlteracao: agora,
    );
    for (final categoria in categorias) {
      categoria.dataAlteracao = agora;
    }
  }

  void _validarCategoriaParaExclusao(Categoria categoria) {
    if (categoria.categoriaPadrao) {
      throw StateError('A categoria padrão não pode ser excluída.');
    }
    if (categoria.id == null || categoria.id! <= 0) {
      throw StateError(
          'A categoria precisa estar persistida para ser excluída.');
    }
  }
}
