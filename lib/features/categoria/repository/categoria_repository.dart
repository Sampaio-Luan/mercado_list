import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_categoria.dart';
import '../model/categoria_mapper.dart';
import '../model/categoria_model.dart';

class CategoriaRepository implements ContratoRepository<Categoria> {
  final BancoLocal bancoLocal;
  final CategoriaMapper categoriaMapper;

  static const _log = '🏷️ CategoriaRepository';

  CategoriaRepository({
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
    log(name: _log, 'criar(): criado com sucesso ! id: $id');
    return recuperar(id);
  }

  @override
  Future<Categoria> editar(Categoria objeto) async {
    final db = await _db;
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
      name: _log,
      'editar(): ${objeto.titulo} editado com sucesso ! id: ${objeto.id}',
    );

    return recuperar(objeto.id!);
  }

  @override
  Future<bool> excluir(int id) async {
    final db = await _db;

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
      name: _log,
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

    log(name: _log, ' recuperar(): $categoria');
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
      name: _log,
      ' recuperarTodos(): depois - ${categorias.length} categorias',
    );
    return categorias;
  }
}
