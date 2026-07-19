import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/logs/logs.dart';
import '../contracts/gerenciador_transacoes.dart';

import 'migrations/migrations.dart';
import 'schema/tb_categoria.dart';
import 'schema/tb_historico.dart';
import 'schema/tb_item.dart';
import 'schema/tb_item_historico.dart';
import 'schema/tb_item_recorrente.dart';
import 'schema/tb_lista.dart';

class BancoLocal implements GerenciadorTransacoes {
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
    _dataBase = await openDatabase(
      join(await getDatabasesPath(), 'mercado_list_local.db'),
      version: 5,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _dataBase!;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(TbCategoria.criarTabela);
    await db.execute(TbCategoria.inserirCategorias);
    await db.execute(TbCategoria.criarIndiceCategoriaPadraoAtiva);
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
    await Migrations.executar(
      db,
      versaoAnterior: oldVersion,
      novaVersao: newVersion,
    );

    log(
      name: LogId.bancolocal,
      '_onUpgrade(): Banco de dados atualizado com sucesso. Versão: $newVersion',
    );
  }

  @override
  Future<T> executar<T>(
    Future<T> Function(DatabaseExecutor executor) operacao,
  ) async {
    final db = await dataBase;
    log(name: LogId.bancolocal, 'executar()');
    return await db.transaction((transaction) async {
      return await operacao(transaction);
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
