import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../model/item_model.dart';
import '../repository/itens_repository.dart';

class ItensService {
  final ItensRepository _repository;

  ItensService(this._repository);

  Future<Item> criar(Item item) {
    return _executar('criar', 'titulo=${item.titulo}', () async {
      item.titulo = item.titulo.trim();
      if (item.titulo.isEmpty) {
        throw ArgumentError('O título do item é obrigatório.');
      }
      if (item.idLista <= 0) throw ArgumentError('A lista é inválida.');
      if (item.idCategoria <= 0) {
        item.idCategoria = await _repository.buscarIdCategoriaPadrao();
      }
      return _repository.criar(item);
    });
  }

  Future<Item> editar(Item item) {
    return _executar('editar', 'item=${item.id}', () {
      item.titulo = item.titulo.trim();
      if (item.titulo.isEmpty) {
        throw ArgumentError('O título do item é obrigatório.');
      }
      return _repository.editar(item);
    });
  }

  Future<void> excluir(Item item) {
    return _executar(
      'excluir',
      'item=${item.id}',
      () => _repository.excluir(item),
    );
  }

  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar('buscarPorLista', 'lista=$idLista', () {
      if (idLista <= 0) throw ArgumentError.value(idLista, 'idLista');
      return _repository.buscarPorLista(
        idLista,
        databaseExecutor: databaseExecutor,
      );
    });
  }

  Future<Item> alterarObtido(Item item, bool obtido) {
    return _executar(
      'alterarObtido',
      'item=${item.id}, obtido=$obtido',
      () {
        final alterado = item.copia(obtido: obtido);
        return _repository.alterarObtido(alterado);
      },
    );
  }

  Future<int> excluirPorLista(
    int idLista, {
    required DateTime dataAlteracao,
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar('excluirPorLista', 'lista=$idLista', () {
      return _repository.excluirPorLista(
        idLista,
        dataAlteracao: dataAlteracao,
        databaseExecutor: databaseExecutor,
      );
    });
  }

  Future<List<Item>> copiarParaLista(
    List<Item> itens,
    int idListaDestino, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'copiarParaLista',
      'itens=${itens.length}, destino=$idListaDestino',
      () => _repository.copiarParaLista(
        itens,
        idListaDestino,
        databaseExecutor: databaseExecutor,
      ),
    );
  }

  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'moverParaCategoria',
      'origem=$categoriaOrigem, destino=$categoriaDestino',
      () => _repository.moverParaCategoria(
        categoriaOrigem: categoriaOrigem,
        categoriaDestino: categoriaDestino,
        databaseExecutor: databaseExecutor,
      ),
    );
  }

  Future<T> _executar<T>(
    String operacao,
    String detalhes,
    Future<T> Function() acao,
  ) async {
    log(
      '$operacao(): iniciando; $detalhes',
      name: LogId.itemService,
    );
    try {
      final resultado = await acao();
      log(
        '$operacao(): concluído com sucesso; $detalhes',
        name: LogId.itemService,
      );
      return resultado;
    } catch (erro, stackTrace) {
      log(
        '$operacao(): $erro',
        name: LogId.itemService,
        error: erro,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
