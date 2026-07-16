import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_categoria.dart';
import '../mapper/categoria_mapper.dart';
import '../model/categoria_model.dart';

class CategoriasRepository implements ContratoRepository<Categoria> {
  final BancoLocal bancoLocal;
  final CategoriaMapper categoriaMapper;

  CategoriasRepository({
    required this.bancoLocal,
    required this.categoriaMapper,
  });

  Future<Database> get _db async => bancoLocal.dataBase;

  @override
  Future<Categoria> criar(Categoria objeto) async {
    final db = await _db;
    int id = await db.insert(
      TbCategoria.nomeTabela,
      categoriaMapper.paraMapa(objeto),
    );
    log(
      name: LogId.categoriaRepository,
      'criar(): criado com sucesso ! id: $id',
    );
    return recuperar(id);
  }

  @override
  Future<Categoria> editar(
    Categoria objeto, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final linhasAfetadas = await db.update(
      TbCategoria.nomeTabela,
      categoriaMapper.paraMapa(objeto),
      where: '${TbCategoria.colunaId} = ?',
      whereArgs: [objeto.id],
    );

    if (linhasAfetadas == 0) {
      throw Exception('Categoria ${objeto.id} nao encontrada.');
    }
    log(
      name: LogId.categoriaRepository,
      'editar(): ${objeto.titulo} editado com sucesso ! id: ${objeto.id}',
    );

    return recuperar(objeto.id!);
  }

  @override
  Future<bool> excluir(int id, {DatabaseExecutor? databaseExecutor}) async {
    final db = databaseExecutor ?? await _db;

    final linhasAfetadas = await db.update(
      TbCategoria.nomeTabela,
      {TbCategoria.colunaEstaExcluido: 1},
      where: '${TbCategoria.colunaId} = ?',
      whereArgs: [id],
    );

    if (linhasAfetadas == 0) {
      throw Exception('Categoria $id nao encontrada.');
    }

    log(
      name: LogId.categoriaRepository,
      'excluir(): Categoria id: $id excluido do banco de dados local com sucesso',
    );

    return true;
  }

  @override
  Future<Categoria> recuperar(int id) async {
    final db = await _db;

    final resultado = await db.query(
      TbCategoria.nomeTabela,
      where: '${TbCategoria.colunaId} = ?',
      whereArgs: [id],
    );

    if (resultado.isEmpty) {
      throw Exception('Categoria $id não encontrada.');
    }
    Categoria categoria = categoriaMapper.doMapa(resultado.first);

    log(name: LogId.categoriaRepository, ' recuperar(): $categoria');
    return categoria;
  }

  @override
  Future<List<Categoria>> recuperarTodos() async {
    final db = await _db;
    final resultado = await db.query(
      TbCategoria.nomeTabela,
      where: '${TbCategoria.colunaEstaExcluido} = ?',
      whereArgs: [0],
      orderBy: TbCategoria.colunaOrdem,
    );

    List<Categoria> categorias = resultado.map(categoriaMapper.doMapa).toList();

    log(
      name: LogId.categoriaRepository,
      ' recuperarTodos(): depois - ${categorias.length} categorias',
    );
    return categorias;
  }

  Future<void> atualizarOrdens(
    List<Categoria> categorias, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    Batch batch = db.batch();
    for (int i = 0; i < categorias.length; i++) {
      batch.update(
        TbCategoria.nomeTabela,
        {
          TbCategoria.colunaOrdem: i,
          TbCategoria.colunaDataAlteracao: DateTime.now().toIso8601String(),
        },
        where: '${TbCategoria.colunaId} = ?',
        whereArgs: [categorias[i].id],
      );
    }
    await batch.commit();
    log(
      name: LogId.categoriaRepository,
      'atualizarOrdens() ${categorias.length} categorias atualizadas com sucesso',
    );
  }
}
