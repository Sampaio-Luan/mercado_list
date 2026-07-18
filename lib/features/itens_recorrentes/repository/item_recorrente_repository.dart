import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_item_recorrente.dart';
import '../mapper/item_recorrente_mapper.dart';
import '../model/item_recorrente_model.dart';

class ItemRecorrenteRepository implements ContratoRepository<ItemRecorrente> {
  final BancoLocal bancoLocal;
  final ItemRecorrenteMapper itemRecorrenteMapper;

  ItemRecorrenteRepository({
    required this.bancoLocal,
    required this.itemRecorrenteMapper,
  });

  Future<Database> get _db async => bancoLocal.dataBase;

  @override
  Future<ItemRecorrente> criar(ItemRecorrente objeto) async {
    final dbLocal = await _db;

    int id = await dbLocal.insert(
      TbItemRecorrente.nomeTabela,
      itemRecorrenteMapper.paraMapa(objeto),
    );

    log(
      name: LogId.itensRecorrentesRepository,
      'criar(): criado com sucesso ! id: $id',
    );
    return recuperar(id);
  }

  @override
  Future<ItemRecorrente> editar(ItemRecorrente objeto) async {
    final dbLocal = await _db;

    final linhasAfetadas = await dbLocal.update(
      TbItemRecorrente.nomeTabela,
      itemRecorrenteMapper.paraMapa(objeto),
      where: '${TbItemRecorrente.colunaId} = ?',
      whereArgs: [objeto.id],
    );

    if (linhasAfetadas == 0) {
      throw Exception('ItemRecorrente ${objeto.id} nao encontrada.');
    }
    log(
      name: LogId.itensRecorrentesRepository,
      'editar(): ${objeto.titulo} editado com sucesso ! id: ${objeto.id}',
    );

    return recuperar(objeto.id!);
  }

  @override
  Future<bool> excluir(int id) async {
    final dbLocal = await _db;
    final linhasAfetadas = await dbLocal.update(
      TbItemRecorrente.nomeTabela,
      {TbItemRecorrente.colunaEstaExcluido: 1},
      where: '${TbItemRecorrente.colunaId} = ?',
      whereArgs: [id],
    );

    if (linhasAfetadas == 0) {
      throw Exception('ItemRecorrente $id nao encontrada.');
    }
    log(
      name: LogId.itensRecorrentesRepository,
      'excluir(): ItemRecorrente id: $id excluido do banco de dados local com sucesso',
    );

    return true;
  }

  @override
  Future<ItemRecorrente> recuperar(int id) async {
    final dbLocal = await _db;

    final resultado = await dbLocal.query(
      TbItemRecorrente.nomeTabela,
      where: '${TbItemRecorrente.colunaId} = ?',
      whereArgs: [id],
    );

    if (resultado.isEmpty) {
      throw Exception('ItemRecorrente $id nao encontrada.');
    }
    ItemRecorrente itemRecorrente = itemRecorrenteMapper.doMapa(
      resultado.first,
    );

    log(
      name: LogId.itensRecorrentesRepository,
      ' recuperar(): $itemRecorrente',
    );
    return itemRecorrente;
  }

  @override
  Future<List<ItemRecorrente>> recuperarTodos() async {
    final dbLocal = await _db;

    final resultado = await dbLocal.query(
      TbItemRecorrente.nomeTabela,
      where: '${TbItemRecorrente.colunaEstaExcluido} = ?',
      whereArgs: [0],
    );

    List<ItemRecorrente> itens =
        resultado.map(itemRecorrenteMapper.doMapa).toList();

    log(name: LogId.itensRecorrentesRepository, ' recuperarTodos(): vazio');

    return itens;
  }

  Future<List<ItemRecorrente>> buscarPorCategoria(
    int idCategoria, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final resultado = await db.query(
      TbItemRecorrente.nomeTabela,
      where: '${TbItemRecorrente.colunaIdCategoria} = ?',
      whereArgs: [idCategoria],
    );

    return resultado.map(itemRecorrenteMapper.doMapa).toList();
  }

  Future<int> atualizarCategoriaDosItens({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final linhasAfetadas = await db.update(
      TbItemRecorrente.nomeTabela,
      {
        TbItemRecorrente.colunaIdCategoria: categoriaDestino,
        TbItemRecorrente.colunaDataAlteracao: DateTime.now().toIso8601String(),
      },
      where: '${TbItemRecorrente.colunaIdCategoria} = ?',
      whereArgs: [categoriaOrigem],
    );

    log(
      name: LogId.itensRecorrentesRepository,
      'atualizarCategoriaDosItens(): $linhasAfetadas itens movidos '
      'da categoria $categoriaOrigem para $categoriaDestino',
    );
    return linhasAfetadas;
  }
}
