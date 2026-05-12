import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  get dataBase async {
    //await mydeleteDatabase();
    if (_dataBase != null) {
      return _dataBase;
    }

    return await _iniciaBancoLocal();
  }

  _iniciaBancoLocal() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'mercado_list.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  _onCreate(db, version) async {

    const String pragma = 'PRAGMA foreign_keys = ON;';

    await db.execute(pragma); // ✅ Ativa as chaves estrangeiras
    await db.execute(TbCategoria.criarTabela);
    await db.execute(TbCategoria.inserirCategorias);
    await db.execute(TbLista.criarTabela);
    await db.execute(TbItem.criarTabela);
    await db.execute(TbItemRecorrente.criarTabela);
    await db.execute(TbHistorico.criarTabela);
    await db.execute(TbItemHistorico.criarTabela);

    debugPrint('Banco local criado com sucesso ✅');
  }
}
