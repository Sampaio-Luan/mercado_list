import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/constants/enums/cor.dart';
import '../../../core/contracts/contrato_repository.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_categoria.dart';
import '../../../core/utils/data_utils.dart';
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
    final agora = DataUtils.agoraUtc();
    objeto
      ..dataCriacao ??= agora
      ..dataAlteracao ??= agora;
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
    if (objeto.id == null || objeto.id! <= 0) {
      throw StateError(
          'A categoria precisa estar persistida para ser editada.');
    }
    final db = databaseExecutor ?? await _db;
    final categoriaPersistida = await recuperar(
      objeto.id!,
      databaseExecutor: db,
    );
    final dataAlteracao = DataUtils.agoraUtc();
    final linhasAfetadas = await db.update(
      TbCategoria.nomeTabela,
      {
        if (!categoriaPersistida.categoriaPadrao)
          TbCategoria.colunaTitulo: objeto.titulo,
        TbCategoria.colunaCor: Cor.obterPorColor(color: objeto.cor).name,
        TbCategoria.colunaDescricao: objeto.descricao,
        TbCategoria.colunaDataAlteracao:
            DataUtils.paraPersistencia(dataAlteracao),
      },
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

    return recuperar(objeto.id!, databaseExecutor: db);
  }

  @override
  Future<void> excluir(
    int id, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    final db = databaseExecutor ?? await _db;

    final linhasAfetadas = await db.update(
      TbCategoria.nomeTabela,
      {
        TbCategoria.colunaExcluido: 1,
        TbCategoria.colunaDataAlteracao: DataUtils.paraPersistencia(
          dataAlteracao ?? DataUtils.agoraUtc(),
        ),
      },
      where: '${TbCategoria.colunaId} = ? AND '
          '${TbCategoria.colunaCategoriaPadrao} = ? AND '
          '${TbCategoria.colunaExcluido} = ?',
      whereArgs: [id, 0, 0],
    );

    if (linhasAfetadas == 0) {
      throw Exception('Categoria $id nao encontrada.');
    }

    log(
      name: LogId.categoriaRepository,
      'excluir(): Categoria id: $id excluido do banco de dados local com sucesso',
    );
  }

  Future<Categoria> buscarCategoriaPadrao({
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;
    final resultado = await db.query(
      TbCategoria.nomeTabela,
      where: '${TbCategoria.colunaCategoriaPadrao} = ? AND '
          '${TbCategoria.colunaExcluido} = ?',
      whereArgs: [1, 0],
    );

    if (resultado.length != 1) {
      throw StateError(
        'Era esperada uma categoria padrão ativa, mas foram encontradas '
        '${resultado.length}.',
      );
    }

    return categoriaMapper.doMapa(resultado.single);
  }

  @override
  Future<Categoria> recuperar(
    int id, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    final db = databaseExecutor ?? await _db;

    final resultado = await db.query(
      TbCategoria.nomeTabela,
      where: '${TbCategoria.colunaId} = ? AND '
          '${TbCategoria.colunaExcluido} = ?',
      whereArgs: [id, 0],
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
      where: '${TbCategoria.colunaExcluido} = ?',
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
    DateTime? dataAlteracao,
  }) async {
    final db = databaseExecutor ?? await _db;
    final dataDaOperacao = dataAlteracao ?? DataUtils.agoraUtc();
    Batch batch = db.batch();
    for (int i = 0; i < categorias.length; i++) {
      batch.update(
        TbCategoria.nomeTabela,
        {
          TbCategoria.colunaOrdem: categorias[i].ordem,
          TbCategoria.colunaDataAlteracao: DataUtils.paraPersistencia(
            dataDaOperacao,
          ),
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
