import 'dart:developer';

import '../../../core/constants/logs/logs.dart';
import '../../../core/contracts/gerenciador_transacoes.dart';
import '../../../core/utils/texto_utils.dart';
import '../model/item_model.dart';
import '../repository/itens_repository.dart';

abstract interface class ItensServiceContract {
  Future<Item> criar(Item item);

  Future<Item> editar(Item item);

  Future<void> excluir(Item item);

  Future<List<Item>> buscarPorLista(
    int idLista, {
    ExecutorTransacao? databaseExecutor,
  });

  Future<Item> alterarObtido(Item item, bool obtido);

  Future<int> excluirPorLista(
    int idLista, {
    required DateTime dataAlteracao,
    ExecutorTransacao? databaseExecutor,
  });

  Future<List<Item>> copiarParaLista(
    List<Item> itens,
    int idListaDestino, {
    ExecutorTransacao? databaseExecutor,
  });

  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    ExecutorTransacao? databaseExecutor,
  });

  Future<Item> somarQuantidade(Item item, int quantidade);
}

class ItensService implements ItensServiceContract {
  final ItensRepositoryContract _repository;

  ItensService(this._repository);

  @override
  Future<Item> criar(Item item) {
    return _executar('criar', 'titulo=${item.titulo}', () async {
      final novo = item.copia(titulo: item.titulo.trim());
      if (novo.titulo.isEmpty) {
        throw ArgumentError('O título do item é obrigatório.');
      }
      if (novo.idLista <= 0) throw ArgumentError('A lista é inválida.');
      if (novo.idCategoria <= 0) {
        novo.idCategoria = await _repository.buscarIdCategoriaPadrao();
      }
      _validarValores(novo);
      return _repository.criar(novo);
    });
  }

  @override
  Future<Item> editar(Item item) {
    return _executar('editar', 'item=${item.id}', () {
      final editado = item.copia(titulo: item.titulo.trim());
      if (editado.titulo.isEmpty) {
        throw ArgumentError('O título do item é obrigatório.');
      }
      if (editado.id == null || editado.id! <= 0) {
        throw ArgumentError('O item precisa estar persistido.');
      }
      if (editado.idLista <= 0 || editado.idCategoria <= 0) {
        throw ArgumentError('A lista e a categoria são obrigatórias.');
      }
      _validarValores(editado);
      return _repository.editar(editado);
    });
  }

  @override
  Future<void> excluir(Item item) {
    return _executar(
      'excluir',
      'item=${item.id}',
      () => _repository.excluir(item),
    );
  }

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    ExecutorTransacao? databaseExecutor,
  }) {
    return _executar('buscarPorLista', 'lista=$idLista', () {
      if (idLista <= 0) throw ArgumentError.value(idLista, 'idLista');
      return _repository.buscarPorLista(
        idLista,
        databaseExecutor: databaseExecutor,
      );
    });
  }

  @override
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

  @override
  Future<int> excluirPorLista(
    int idLista, {
    required DateTime dataAlteracao,
    ExecutorTransacao? databaseExecutor,
  }) {
    return _executar('excluirPorLista', 'lista=$idLista', () {
      return _repository.excluirPorLista(
        idLista,
        dataAlteracao: dataAlteracao,
        databaseExecutor: databaseExecutor,
      );
    });
  }

  @override
  Future<List<Item>> copiarParaLista(
    List<Item> itens,
    int idListaDestino, {
    ExecutorTransacao? databaseExecutor,
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

  @override
  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    ExecutorTransacao? databaseExecutor,
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

  @override
  Future<Item> somarQuantidade(Item item, int quantidade) {
    if (quantidade <= 0) throw ArgumentError('A quantidade deve ser positiva.');
    return editar(item.copia(
      quantidade: (item.quantidade ?? 0) + quantidade,
    ));
  }

  static Item? localizarDuplicado(Iterable<Item> itens, String titulo) {
    final normalizado = TextoUtils.normalizarParaOrdenacao(titulo);
    for (final item in itens) {
      if (TextoUtils.normalizarParaOrdenacao(item.titulo) == normalizado) {
        return item;
      }
    }
    return null;
  }

  void _validarValores(Item item) {
    if (item.quantidade != null && item.quantidade! <= 0) {
      throw ArgumentError('A quantidade deve ser positiva.');
    }
    if (item.preco != null && item.preco! < 0) {
      throw ArgumentError('O preço não pode ser negativo.');
    }
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
