import 'package:sqflite/sqflite.dart';

import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';

class CategoriasService {
  final CategoriasRepository _repository;

  CategoriasService(this._repository);

  Future<List<Categoria>> recuperarTodos() {
    return _repository.recuperarTodos();
  }

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

  Future<void> excluir(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    _validarCategoriaParaExclusao(categoria);
    await _repository.excluir(
      categoria.id!,
      databaseExecutor: databaseExecutor,
    );
  }

  Future<void> atualizarOrdens(List<Categoria> categorias) {
    if (categorias.any((categoria) => categoria.id == null)) {
      throw StateError('Todas as categorias devem estar persistidas.');
    }
    return _repository.atualizarOrdens(categorias);
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
