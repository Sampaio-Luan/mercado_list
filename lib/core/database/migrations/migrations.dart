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
    if (versaoAnterior < 6 && novaVersao >= 6) {
      await paraVersao6(db);
    }
    if (versaoAnterior < 7 && novaVersao >= 7) {
      await paraVersao7(db);
    }
    if (versaoAnterior < 8 && novaVersao >= 8) {
      await paraVersao8(db);
    }
    if (versaoAnterior < 9 && novaVersao >= 9) {
      await paraVersao9(db);
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

  static Future<void> paraVersao6(DatabaseExecutor db) async {
    await db.execute('''
      ALTER TABLE ${TbLista.nomeTabela}
      ADD COLUMN ${TbLista.colunaCor} TEXT NOT NULL DEFAULT 'indigo'
    ''');
    await db.execute('''
      ALTER TABLE ${TbLista.nomeTabela}
      ADD COLUMN ${TbLista.colunaOrcamento} INTEGER
    ''');
    await db.execute('''
      ALTER TABLE ${TbLista.nomeTabela}
      ADD COLUMN ${TbLista.colunaOrdem} INTEGER NOT NULL DEFAULT 0
    ''');
    await db.execute('''
      ALTER TABLE ${TbLista.nomeTabela}
      ADD COLUMN ${TbLista.colunaFixada} INTEGER NOT NULL DEFAULT 0
        CHECK (${TbLista.colunaFixada} IN (0, 1))
    ''');
    await db.execute('''
      UPDATE ${TbLista.nomeTabela}
      SET ${TbLista.colunaOrdem} = ${TbLista.colunaId}
    ''');
    await db.execute(TbLista.criarIndiceOrdenacao);
    await db.execute(TbItem.criarIndiceLista);
  }

  static Future<void> paraVersao7(DatabaseExecutor db) async {
    await db.execute(TbLista.inserirListaExemploSeAusente);
    await db.execute(TbItem.inserirItensExemploSeAusentes);
  }

  static Future<void> paraVersao8(DatabaseExecutor db) async {
    await db.execute(TbLista.atualizarDescricaoListaExemplo);
    await db.execute(TbItem.excluirDicasAntigasDaListaExemplo);
    await db.execute(TbItem.inserirItensExemploSeAusentes);
  }

  /// Quantidades de itens em kg passam a ser persistidas em gramas.
  static Future<void> paraVersao9(DatabaseExecutor db) async {
    await db.execute('''
      UPDATE ${TbItem.nomeTabela}
      SET ${TbItem.colunaQuantidade} = ${TbItem.colunaQuantidade} * 1000
      WHERE ${TbItem.colunaUnidadeMedida} = 'kg'
        AND ${TbItem.colunaQuantidade} IS NOT NULL
    ''');
    await db.execute('''
      UPDATE ${TbItemHistorico.nomeTabela}
      SET ${TbItemHistorico.colunaQuantidade} =
          ${TbItemHistorico.colunaQuantidade} * 1000
      WHERE ${TbItemHistorico.colunaUnidadeDeMedida} = 'kg'
    ''');
  }
}
