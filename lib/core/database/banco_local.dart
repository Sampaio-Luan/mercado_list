import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/logs/logs.dart';

import 'schema/tb_categoria.dart';
import 'schema/tb_historico.dart';
import 'schema/tb_item.dart';
import 'schema/tb_item_historico.dart';
import 'schema/tb_item_recorrente.dart';
import 'schema/tb_lista.dart';

class BancoLocal {
  BancoLocal._();

  static final BancoLocal _instancia = BancoLocal._();
  static BancoLocal get instancia => _instancia;

  static Database? _dataBase;

  Future<Database> get dataBase async {
    //await _deletarBanco();
    if (_dataBase != null) {
      return _dataBase!;
    }

    return await _iniciaBancoLocal();
  }

  Future<Database> _iniciaBancoLocal() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'mercado_list_local.db'),
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    const String pragma = 'PRAGMA foreign_keys = ON;';

    await db.execute(pragma); // ✅ Ativa as chaves estrangeiras
    await db.execute(TbCategoria.criarTabela);
    await db.execute(TbCategoria.inserirCategorias);
    await db.execute(TbItemRecorrente.criarTabela);
    await db.execute(TbItemRecorrente.inserirItensRecorrentes);
    await db.execute(TbLista.criarTabela);
    await db.execute(TbItem.criarTabela);
    await db.execute(TbHistorico.criarTabela);
    await db.execute(TbItemHistorico.criarTabela);

    log(
      name: LogId.bancolocal,
      '_onCreate(): Banco de dados criado com sucesso. Versão: $version',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
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

      log(
        name: LogId.bancolocal,
        '_onUpgrade(): Banco de dados atualizado com sucesso. Versão: $newVersion',
      );
    }
  }

  Future<T> executarEmTransacao<T>(
    Future<T> Function(Transaction transaction) acao,
  ) async {
    final db = await dataBase;
    log(name: LogId.bancolocal, 'executarTransacao()');
    return await db.transaction((transaction) async {
      return await acao(transaction);
    });
  }

  // Future<void> _deletarBanco () async {
  //   String path = join(await getDatabasesPath(), 'mercado_list.db');
  //   await deleteDatabase(path);
  //   log(
  //     name:LogId.bancolocal,
  //     '_deletarBanco (): Banco de dados deletado com sucesso.',
  //   );
  // }
}
