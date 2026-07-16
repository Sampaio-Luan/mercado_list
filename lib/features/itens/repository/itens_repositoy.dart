import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/database/schema/tb_item.dart';

class ItensRepository {
Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor ? databaseExecutor
  }) async {
    //final dbLocal =  executor ?? await _db;
    //     final linhasAfetadas = await dbLocal.update(
    //   TbItem.nomeTabela,
    //   {
    //     TbItem.colunaIdCategoria: categoriaDestino,
    //   },
    //   where:
    //       '${TbItem.colunaIdCategoria} = ? AND '
    //       '${TbItem.colunaEstaExcluido} = ?',
    //   whereArgs: [
    //     categoriaOrigem,
    //     0,
    //   ],
    // );

    final linhasAfetadas = 0;
    log(
      name: LogId.itemRepository,
      'moverParaCategoria(): $linhasAfetadas itens recorrentes movidos '
      'da categoria $categoriaOrigem para $categoriaDestino',
    );
    return linhasAfetadas;
  }
}
