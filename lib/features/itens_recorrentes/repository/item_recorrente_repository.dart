import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_item_recorrente.dart';
import '../../../core/utils/data_utils.dart';
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
    final agora = DataUtils.agoraUtc();
    objeto
      ..dataCriacao ??= agora
      ..dataAlteracao ??= agora;

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
    objeto.dataAlteracao = DataUtils.agoraUtc();

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
  Future<void> excluir(int id) async {
    final dbLocal = await _db;
    final linhasAfetadas = await dbLocal.update(
      TbItemRecorrente.nomeTabela,
      {
        TbItemRecorrente.colunaExcluido: 1,
        TbItemRecorrente.colunaDataAlteracao: DataUtils.paraPersistencia(
          DataUtils.agoraUtc(),
        ),
      },
      where: '${TbItemRecorrente.colunaId} = ? AND '
          '${TbItemRecorrente.colunaExcluido} = ?',
      whereArgs: [id, 0],
    );

    if (linhasAfetadas == 0) {
      throw Exception('ItemRecorrente $id nao encontrada.');
    }
    log(
      name: LogId.itensRecorrentesRepository,
      'excluir(): ItemRecorrente id: $id excluido do banco de dados local com sucesso',
    );
  }

  @override
  Future<ItemRecorrente> recuperar(int id) async {
    final dbLocal = await _db;

    final resultado = await dbLocal.query(
      TbItemRecorrente.nomeTabela,
      where: '${TbItemRecorrente.colunaId} = ? AND '
          '${TbItemRecorrente.colunaExcluido} = ?',
      whereArgs: [id, 0],
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
      where: '${TbItemRecorrente.colunaExcluido} = ?',
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
      where: '${TbItemRecorrente.colunaIdCategoria} = ? AND '
          '${TbItemRecorrente.colunaExcluido} = ?',
      whereArgs: [idCategoria, 0],
    );

    return resultado.map(itemRecorrenteMapper.doMapa).toList();
  }

  Future<int> atualizarCategoriaDosItens({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    final db = databaseExecutor ?? await _db;
    final linhasAfetadas = await db.update(
      TbItemRecorrente.nomeTabela,
      {
        TbItemRecorrente.colunaIdCategoria: categoriaDestino,
        TbItemRecorrente.colunaDataAlteracao: DataUtils.paraPersistencia(
          dataAlteracao ?? DataUtils.agoraUtc(),
        ),
      },
      where: '${TbItemRecorrente.colunaIdCategoria} = ? AND '
          '${TbItemRecorrente.colunaExcluido} = ?',
      whereArgs: [categoriaOrigem, 0],
    );

    log(
      name: LogId.itensRecorrentesRepository,
      'atualizarCategoriaDosItens(): $linhasAfetadas itens movidos '
      'da categoria $categoriaOrigem para $categoriaDestino',
    );
    return linhasAfetadas;
  }

  Future<ItemRecorrente> moverItemParaCategoria({
    required int idItem,
    required int categoriaOrigem,
    required int categoriaDestino,
  }) async {
    final db = await _db;
    final linhasAfetadas = await db.update(
      TbItemRecorrente.nomeTabela,
      {
        TbItemRecorrente.colunaIdCategoria: categoriaDestino,
        TbItemRecorrente.colunaDataAlteracao: DataUtils.paraPersistencia(
          DataUtils.agoraUtc(),
        ),
      },
      where: '${TbItemRecorrente.colunaId} = ? AND '
          '${TbItemRecorrente.colunaIdCategoria} = ? AND '
          '${TbItemRecorrente.colunaExcluido} = ?',
      whereArgs: [idItem, categoriaOrigem, 0],
    );

    if (linhasAfetadas != 1) {
      throw StateError(
        'Não foi possível mover o item recorrente $idItem.',
      );
    }
    return recuperar(idItem);
  }

  Future<List<ItemRecorrente>> moverItensParaCategoria({
    required List<int> idsItens,
    required int categoriaOrigem,
    required int categoriaDestino,
  }) {
    return bancoLocal.executar((executor) async {
      final marcadores = List.filled(idsItens.length, '?').join(', ');
      final dataAlteracao = DataUtils.agoraUtc();
      final linhasAfetadas = await executor.update(
        TbItemRecorrente.nomeTabela,
        {
          TbItemRecorrente.colunaIdCategoria: categoriaDestino,
          TbItemRecorrente.colunaDataAlteracao:
              DataUtils.paraPersistencia(dataAlteracao),
        },
        where: '${TbItemRecorrente.colunaId} IN ($marcadores) AND '
            '${TbItemRecorrente.colunaIdCategoria} = ? AND '
            '${TbItemRecorrente.colunaExcluido} = ?',
        whereArgs: [...idsItens, categoriaOrigem, 0],
      );

      if (linhasAfetadas != idsItens.length) {
        throw StateError(
          'Não foi possível mover todos os itens recorrentes: '
          '${idsItens.length} esperados e $linhasAfetadas atualizados.',
        );
      }

      final resultado = await executor.query(
        TbItemRecorrente.nomeTabela,
        where: '${TbItemRecorrente.colunaId} IN ($marcadores) AND '
            '${TbItemRecorrente.colunaIdCategoria} = ? AND '
            '${TbItemRecorrente.colunaExcluido} = ?',
        whereArgs: [...idsItens, categoriaDestino, 0],
      );

      log(
        name: LogId.itensRecorrentesRepository,
        'moverItensParaCategoria(): $linhasAfetadas itens movidos '
        'da categoria $categoriaOrigem para $categoriaDestino',
      );
      return resultado.map(itemRecorrenteMapper.doMapa).toList();
    });
  }

  Future<void> excluirItens(List<int> idsItens) {
    return bancoLocal.executar((executor) async {
      final marcadores = List.filled(idsItens.length, '?').join(', ');
      final linhasAfetadas = await executor.update(
        TbItemRecorrente.nomeTabela,
        {
          TbItemRecorrente.colunaExcluido: 1,
          TbItemRecorrente.colunaDataAlteracao: DataUtils.paraPersistencia(
            DataUtils.agoraUtc(),
          ),
        },
        where: '${TbItemRecorrente.colunaId} IN ($marcadores) AND '
            '${TbItemRecorrente.colunaExcluido} = ?',
        whereArgs: [...idsItens, 0],
      );

      if (linhasAfetadas != idsItens.length) {
        throw StateError(
          'Não foi possível excluir todos os itens recorrentes: '
          '${idsItens.length} esperados e $linhasAfetadas atualizados.',
        );
      }
      log(
        name: LogId.itensRecorrentesRepository,
        'excluirItens(): $linhasAfetadas itens excluídos',
      );
    });
  }
}
