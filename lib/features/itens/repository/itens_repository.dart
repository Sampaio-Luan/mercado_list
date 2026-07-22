import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_categoria.dart';
import '../../../core/database/schema/tb_item.dart';
import '../../../core/utils/data_utils.dart';
import '../mapper/item_mapper.dart';
import '../model/item_model.dart';

class ItensRepository {
  final BancoLocal bancoLocal;
  final ItemMapper itemMapper;

  ItensRepository({required this.bancoLocal, required this.itemMapper});

  Future<Database> get _db async => bancoLocal.dataBase;

  Future<Item> criar(
    Item item, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'criar',
      'titulo=${item.titulo}, lista=${item.idLista}',
      () => _criar(item, databaseExecutor: databaseExecutor),
    );
  }

  Future<Item> _criar(
    Item item, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final agora = DataUtils.agoraUtc();
    item
      ..dataCriacao ??= agora
      ..dataAlteracao ??= agora;
    final id = await db.insert(TbItem.nomeTabela, itemMapper.paraMapa(item));
    return recuperar(id, databaseExecutor: db);
  }

  Future<Item> editar(Item item) {
    return _executar(
      'editar',
      'item=${item.id}',
      () => _editar(item),
    );
  }

  Future<Item> _editar(Item item) async {
    if (item.id == null) throw StateError('O item precisa estar persistido.');
    final db = await _db;
    item.dataAlteracao = DataUtils.agoraUtc();
    final valores = itemMapper.paraMapa(item)
      ..remove(TbItem.colunaId)
      ..remove(TbItem.colunaDataCriacao);
    final linhas = await db.update(
      TbItem.nomeTabela,
      valores,
      where: '${TbItem.colunaId} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [item.id],
    );
    if (linhas == 0) throw StateError('Item ${item.id} não encontrado.');
    return recuperar(item.id!, databaseExecutor: db);
  }

  Future<void> excluir(Item item) {
    return _executar(
      'excluir',
      'item=${item.id}',
      () => _excluir(item),
    );
  }

  Future<void> _excluir(Item item) async {
    if (item.id == null) throw StateError('O item precisa estar persistido.');
    final db = await _db;
    final linhas = await db.update(
      TbItem.nomeTabela,
      {
        TbItem.colunaExcluido: 1,
        TbItem.colunaDataAlteracao:
            DataUtils.paraPersistencia(DataUtils.agoraUtc()),
      },
      where: '${TbItem.colunaId} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [item.id],
    );
    if (linhas == 0) throw StateError('Item ${item.id} não encontrado.');
  }

  Future<int> buscarIdCategoriaPadrao() {
    return _executar(
      'buscarIdCategoriaPadrao',
      'categoria padrão ativa',
      _buscarIdCategoriaPadrao,
    );
  }

  Future<int> _buscarIdCategoriaPadrao() async {
    final db = await _db;
    final resultado = await db.query(
      TbCategoria.nomeTabela,
      columns: [TbCategoria.colunaId],
      where: '${TbCategoria.colunaCategoriaPadrao} = 1 '
          'AND ${TbCategoria.colunaExcluido} = 0',
      limit: 1,
    );
    if (resultado.isEmpty) {
      throw StateError('A categoria padrão não foi encontrada.');
    }
    return resultado.single[TbCategoria.colunaId] as int;
  }

  Future<Item> recuperar(
    int id, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'recuperar',
      'item=$id',
      () => _recuperar(id, databaseExecutor: databaseExecutor),
    );
  }

  Future<Item> _recuperar(
    int id, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final resultado = await db.query(
      TbItem.nomeTabela,
      where: '${TbItem.colunaId} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [id],
    );
    if (resultado.isEmpty) throw StateError('Item $id não encontrado.');
    return itemMapper.doMapa(resultado.single);
  }

  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'buscarPorLista',
      'lista=$idLista',
      () => _buscarPorLista(idLista, databaseExecutor: databaseExecutor),
    );
  }

  Future<List<Item>> _buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final resultado = await db.query(
      TbItem.nomeTabela,
      where: '${TbItem.colunaIdLista} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [idLista],
      orderBy: '${TbItem.colunaObtido}, ${TbItem.colunaPrioridade} DESC, '
          '${TbItem.colunaTitulo} COLLATE NOCASE',
    );
    return resultado.map(itemMapper.doMapa).toList();
  }

  Future<Item> alterarObtido(
    Item item, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'alterarObtido',
      'item=${item.id}, obtido=${item.obtido}',
      () => _alterarObtido(item, databaseExecutor: databaseExecutor),
    );
  }

  Future<Item> _alterarObtido(
    Item item, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    if (item.id == null) throw StateError('O item precisa estar persistido.');
    final db = databaseExecutor ?? await _db;
    await db.update(
      TbItem.nomeTabela,
      {
        TbItem.colunaObtido: item.obtido ? 1 : 0,
        TbItem.colunaDataAlteracao:
            DataUtils.paraPersistencia(DataUtils.agoraUtc()),
      },
      where: '${TbItem.colunaId} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [item.id],
    );
    return recuperar(item.id!, databaseExecutor: db);
  }

  Future<int> excluirPorLista(
    int idLista, {
    required DateTime dataAlteracao,
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'excluirPorLista',
      'lista=$idLista',
      () => _excluirPorLista(
        idLista,
        dataAlteracao: dataAlteracao,
        databaseExecutor: databaseExecutor,
      ),
    );
  }

  Future<int> _excluirPorLista(
    int idLista, {
    required DateTime dataAlteracao,
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    return db.update(
      TbItem.nomeTabela,
      {
        TbItem.colunaExcluido: 1,
        TbItem.colunaDataAlteracao: DataUtils.paraPersistencia(dataAlteracao),
      },
      where: '${TbItem.colunaIdLista} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [idLista],
    );
  }

  Future<List<Item>> copiarParaLista(
    List<Item> itens,
    int idListaDestino, {
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'copiarParaLista',
      'itens=${itens.length}, destino=$idListaDestino',
      () => _copiarParaLista(
        itens,
        idListaDestino,
        databaseExecutor: databaseExecutor,
      ),
    );
  }

  Future<List<Item>> _copiarParaLista(
    List<Item> itens,
    int idListaDestino, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final copiados = <Item>[];
    for (final item in itens) {
      final copia = item.copia(idLista: idListaDestino, obtido: false)
        ..id = null
        ..dataCriacao = null
        ..dataAlteracao = null
        ..excluido = false;
      copiados.add(await criar(copia, databaseExecutor: db));
    }
    return copiados;
  }

  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) {
    return _executar(
      'moverParaCategoria',
      'origem=$categoriaOrigem, destino=$categoriaDestino',
      () => _moverParaCategoria(
        categoriaOrigem: categoriaOrigem,
        categoriaDestino: categoriaDestino,
        databaseExecutor: databaseExecutor,
      ),
    );
  }

  Future<int> _moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    return db.update(
      TbItem.nomeTabela,
      {
        TbItem.colunaIdCategoria: categoriaDestino,
        TbItem.colunaDataAlteracao:
            DataUtils.paraPersistencia(DataUtils.agoraUtc()),
      },
      where: '${TbItem.colunaIdCategoria} = ? AND ${TbItem.colunaExcluido} = 0',
      whereArgs: [categoriaOrigem],
    );
  }

  Future<T> _executar<T>(
    String operacao,
    String detalhes,
    Future<T> Function() acao,
  ) async {
    log(
      '$operacao(): iniciando; $detalhes',
      name: LogId.itemRepository,
    );
    try {
      final resultado = await acao();
      log(
        '$operacao(): concluído com sucesso; $detalhes',
        name: LogId.itemRepository,
      );
      return resultado;
    } catch (erro, stackTrace) {
      log(
        '$operacao(): $erro',
        name: LogId.itemRepository,
        error: erro,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
