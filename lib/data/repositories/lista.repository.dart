import 'package:flutter/material.dart';

import 'package:sqflite/sqlite_api.dart';

import '../db/banco_local.dart';
import '../db/schema/tb_item.dart';
import '../db/schema/tb_lista.dart';
import '../model/lista.module.dart';

import 'contrato.repository.dart';

class ListaRepository extends ChangeNotifier
    implements ContratoRepository<Lista> {
  static const String msgId = '🗒️Lista Repository: ';
  late Database dbLocal;
  List<Lista> listas = [];

  ListaRepository() {
    _iniciarRepositorio();
  }

  void _iniciarRepositorio() async {
    if (listas.isEmpty) {
      await recuperarTodos();
      debugPrint(
          '$msgId _iniciarRepositorio(): precisou iniciar o repositorio ');
    }
  }

  @override
  Future criar(Lista objeto) async {
    dbLocal = await BancoLocal.instancia.dataBase;
    debugPrint('$msgId criar(): objeto: $objeto antes de salvar');
    debugPrint(
        '$msgId criar(): tamanho da lista: ${listas.length} antes de salvar');

    int id = await dbLocal.insert(
      TbLista.nomeTabela,
      objeto.paraBd(objeto),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    Lista l = await dbLocal
        .rawQuery(
            'SELECT * FROM ${TbLista.nomeTabela} WHERE ${TbLista.colunaId} = $id')
        .then((value) => objeto.doBd(value.first));

    listas.add(l);
    debugPrint('$msgId criar(): objeto: $l depois de salvar');
    debugPrint(
        '$msgId criar(): tamanho da lista: ${listas.length} depois de salvar');

    debugPrint('$msgId criar(): lista criada com id: $id');
    notifyListeners();
  }

  @override
  Future editar(Lista objeto) async {
    dbLocal = await BancoLocal.instancia.dataBase;

    await dbLocal.update(TbLista.nomeTabela, objeto.paraBd(objeto),
        where: '${TbLista.colunaId} = ?', whereArgs: [objeto.id]);

    listas.removeWhere((e) => e.id == objeto.id);
    listas.add(objeto);

    debugPrint('$msgId editar(): objeto: $objeto depois de editar');

    notifyListeners();
  }

  @override
  Future excluir(int id) async {
    dbLocal = await BancoLocal.instancia.dataBase;
    String timesStamp = DateTime.now().toIso8601String();

    await dbLocal.update(
      TbItem.nomeTabela,
      {
        TbItem.colunaEstaExcluido: 1,
        TbItem.colunaDataAlteracao: timesStamp
      },
      where: '${TbItem.colunaIdLista} = ?',
      whereArgs: [id],
    );

    await dbLocal.update(
      TbLista.nomeTabela,
      {
        TbLista.colunaEstaExcluido: 1,
        TbLista.colunaDataAlteracao: timesStamp
      },
      where: '${TbLista.colunaId} = ?',
      whereArgs: [id],
    );
    listas.removeWhere((e) => e.id == id);
    debugPrint('$msgId excluir(): id: $id e todos os itens da lista (com soft delete)');
    notifyListeners();
  }

  @override
  Future recuperar(int id) async {
    dbLocal = await BancoLocal.instancia.dataBase;

    final List<Map<String, dynamic>> maps = await dbLocal.rawQuery(
        'SELECT * FROM ${TbLista.nomeTabela} WHERE ${TbLista.colunaId} = $id');
    listas.add(Lista.padrao().doBd(maps.first));

    debugPrint('$msgId recuperar(): id: $id');

    notifyListeners();
  }

  @override
  Future recuperarTodos() async {
    dbLocal = await BancoLocal.instancia.dataBase;

    final List<Map<String, dynamic>> maps =
        await dbLocal.rawQuery(TbLista.recuperarTodos);
    listas = List.generate(maps.length, (i) {
      return Lista.padrao().doBd(maps[i]);
    });
    debugPrint('$msgId recuperarTodos(): ${listas.length} listas');

    notifyListeners();
  }
}
