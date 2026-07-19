import 'package:sqflite/sqflite.dart';

import '../../constants/categoria_padrao_constantes.dart';
import '../schema/colunas_entidade.dart';
import '../schema/tb_categoria.dart';
import '../schema/tb_historico.dart';
import '../schema/tb_item.dart';
import '../schema/tb_item_historico.dart';
import '../schema/tb_item_recorrente.dart';
import '../schema/tb_lista.dart';

class Migrations {
  Migrations._();

  static Future<void> executar(
    DatabaseExecutor db, {
    required int versaoAnterior,
    required int novaVersao,
  }) async {
    if (versaoAnterior < 2 && novaVersao >= 2) {
      await paraVersao2(db);
    }
    if (versaoAnterior < 3 && novaVersao >= 3) {
      await paraVersao3(db);
    }
    if (versaoAnterior < 4 && novaVersao >= 4) {
      await paraVersao4(db);
    }
    if (versaoAnterior < 5 && novaVersao >= 5) {
      await paraVersao5(db);
    }
  }

  static Future<void> paraVersao2(DatabaseExecutor db) async {
    await db.execute('''
      ALTER TABLE ${TbCategoria.nomeTabela}
      ADD COLUMN ${TbCategoria.colunaCategoriaPadrao}
      INTEGER NOT NULL DEFAULT 0
    ''');

    await db.update(
      TbCategoria.nomeTabela,
      {TbCategoria.colunaCategoriaPadrao: 1},
      where: '${TbCategoria.colunaTitulo} = ?',
      whereArgs: ['Outros'],
    );
  }

  static Future<void> paraVersao3(DatabaseExecutor db) async {
    for (final tabela in <String>[
      TbCategoria.nomeTabela,
      TbItemRecorrente.nomeTabela,
      TbLista.nomeTabela,
      TbItem.nomeTabela,
      TbHistorico.nomeTabela,
      TbItemHistorico.nomeTabela,
    ]) {
      await db.execute('''
        ALTER TABLE $tabela
        RENAME COLUMN esta_excluido TO ${ColunasEntidade.excluido}
      ''');
    }

    await db.execute('''
      ALTER TABLE ${TbItemHistorico.nomeTabela}
      RENAME COLUMN data_criacao TO ${ColunasEntidade.dataCriacao}
    ''');
    await db.execute('''
      ALTER TABLE ${TbItemHistorico.nomeTabela}
      RENAME COLUMN data_alteracao TO ${ColunasEntidade.dataAlteracao}
    ''');
  }

  static Future<void> paraVersao4(DatabaseExecutor db) async {
    await db.update(
      TbCategoria.nomeTabela,
      {TbCategoria.colunaTitulo: CategoriaPadraoConstantes.titulo},
      where: '${TbCategoria.colunaCategoriaPadrao} = ?',
      whereArgs: [1],
    );
  }

  static Future<void> paraVersao5(DatabaseExecutor db) async {
    await db.execute(TbCategoria.criarIndiceCategoriaPadraoAtiva);
  }
}
