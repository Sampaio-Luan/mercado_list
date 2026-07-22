import 'package:sqflite/sqflite.dart';

import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_item.dart';
import '../../../core/database/schema/tb_lista.dart';
import '../../../core/utils/data_utils.dart';
import '../mapper/lista_mapper.dart';
import '../model/lista_com_resumo_de_itens_model.dart';
import '../model/lista_model.dart';

abstract interface class ListaRepositoryContract
    implements ContratoRepository<Lista> {
  @override
  Future<Lista> criar(Lista lista, {DatabaseExecutor? databaseExecutor});

  @override
  Future<Lista> editar(Lista lista, {DatabaseExecutor? databaseExecutor});

  @override
  Future<Lista> recuperar(int id, {DatabaseExecutor? databaseExecutor});

  @override
  Future<void> excluir(
    int id, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  });

  Future<List<ListaComResumoDeItens>> recuperarComResumo();

  Future<List<Lista>> recuperarTodosNoExecutor(DatabaseExecutor executor);

  Future<int> contarFixadas({DatabaseExecutor? databaseExecutor});

  Future<void> atualizarOrdens(
    List<Lista> listas, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  });
}

class ListaRepository implements ListaRepositoryContract {
  final BancoLocal bancoLocal;
  final ListaMapper listaMapper;

  ListaRepository({required this.bancoLocal, required this.listaMapper});

  Future<Database> get _db async => bancoLocal.dataBase;

  @override
  Future<Lista> criar(
    Lista lista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final agora = DataUtils.agoraUtc();
    final maximo = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT MAX(${TbLista.colunaOrdem}) FROM ${TbLista.nomeTabela} '
            'WHERE ${TbLista.colunaExcluido} = 0',
          ),
        ) ??
        -1;
    lista
      ..ordem = maximo + 1
      ..dataCriacao ??= agora
      ..dataAlteracao ??= agora;
    final id = await db.insert(
      TbLista.nomeTabela,
      listaMapper.paraMapa(lista),
    );
    return recuperar(id, databaseExecutor: db);
  }

  @override
  Future<Lista> editar(
    Lista lista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    if (lista.id == null || lista.id! <= 0) {
      throw StateError('A lista precisa estar persistida para ser editada.');
    }
    final db = databaseExecutor ?? await _db;
    final persistida = await recuperar(lista.id!, databaseExecutor: db);
    lista
      ..ordem = persistida.ordem
      ..dataCriacao = persistida.dataCriacao
      ..dataAlteracao = DataUtils.agoraUtc()
      ..excluido = persistida.excluido;
    final linhas = await db.update(
      TbLista.nomeTabela,
      listaMapper.paraMapa(lista)..remove(TbLista.colunaId),
      where: '${TbLista.colunaId} = ? AND ${TbLista.colunaExcluido} = 0',
      whereArgs: [lista.id],
    );
    if (linhas == 0) throw StateError('Lista ${lista.id} não encontrada.');
    return recuperar(lista.id!, databaseExecutor: db);
  }

  @override
  Future<void> excluir(
    int id, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    final db = databaseExecutor ?? await _db;
    final linhas = await db.update(
      TbLista.nomeTabela,
      {
        TbLista.colunaExcluido: 1,
        TbLista.colunaFixada: 0,
        TbLista.colunaDataAlteracao: DataUtils.paraPersistencia(
          dataAlteracao ?? DataUtils.agoraUtc(),
        ),
      },
      where: '${TbLista.colunaId} = ? AND ${TbLista.colunaExcluido} = 0',
      whereArgs: [id],
    );
    if (linhas == 0) throw StateError('Lista $id não encontrada.');
  }

  @override
  Future<Lista> recuperar(
    int id, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final resultado = await db.query(
      TbLista.nomeTabela,
      where: '${TbLista.colunaId} = ? AND ${TbLista.colunaExcluido} = 0',
      whereArgs: [id],
    );
    if (resultado.isEmpty) throw StateError('Lista $id não encontrada.');
    return listaMapper.doMapa(resultado.single);
  }

  @override
  Future<List<Lista>> recuperarTodos() async {
    final db = await _db;
    return recuperarTodosNoExecutor(db);
  }

  @override
  Future<List<Lista>> recuperarTodosNoExecutor(
      DatabaseExecutor executor) async {
    final resultado = await executor.query(
      TbLista.nomeTabela,
      where: '${TbLista.colunaExcluido} = 0',
      orderBy: '${TbLista.colunaFixada} DESC, ${TbLista.colunaOrdem}, '
          '${TbLista.colunaId}',
    );
    return resultado.map(listaMapper.doMapa).toList();
  }

  @override
  Future<List<ListaComResumoDeItens>> recuperarComResumo() async {
    final db = await _db;
    final resultado = await db.rawQuery('''
      SELECT lista.*,
             COUNT(item.${TbItem.colunaId}) AS quantidade_itens,
             COALESCE(SUM(CASE WHEN item.${TbItem.colunaObtido} = 1
                               THEN 1 ELSE 0 END), 0) AS quantidade_marcados
      FROM ${TbLista.nomeTabela} lista
      LEFT JOIN ${TbItem.nomeTabela} item
        ON item.${TbItem.colunaIdLista} = lista.${TbLista.colunaId}
       AND item.${TbItem.colunaExcluido} = 0
      WHERE lista.${TbLista.colunaExcluido} = 0
      GROUP BY lista.${TbLista.colunaId}
      ORDER BY lista.${TbLista.colunaFixada} DESC,
               lista.${TbLista.colunaOrdem}, lista.${TbLista.colunaId}
    ''');
    return resultado.map((mapa) {
      return ListaComResumoDeItens(
        lista: listaMapper.doMapa(mapa),
        quantidadeItens: mapa['quantidade_itens'] as int,
        quantidadeItensMarcados: mapa['quantidade_marcados'] as int,
      );
    }).toList();
  }

  @override
  Future<int> contarFixadas({DatabaseExecutor? databaseExecutor}) async {
    final db = databaseExecutor ?? await _db;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${TbLista.nomeTabela} '
            'WHERE ${TbLista.colunaFixada} = 1 '
            'AND ${TbLista.colunaExcluido} = 0',
          ),
        ) ??
        0;
  }

  @override
  Future<void> atualizarOrdens(
    List<Lista> listas, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    final db = databaseExecutor ?? await _db;
    final agora = dataAlteracao ?? DataUtils.agoraUtc();
    final lote = db.batch();
    for (var indice = 0; indice < listas.length; indice++) {
      listas[indice]
        ..ordem = indice
        ..dataAlteracao = agora;
      lote.update(
        TbLista.nomeTabela,
        {
          TbLista.colunaOrdem: indice,
          TbLista.colunaDataAlteracao: DataUtils.paraPersistencia(agora),
        },
        where: '${TbLista.colunaId} = ?',
        whereArgs: [listas[indice].id],
      );
    }
    await lote.commit(noResult: true);
  }
}
