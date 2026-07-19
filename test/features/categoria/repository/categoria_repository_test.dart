import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/core/database/banco_local.dart';
import 'package:mercado_list/core/database/schema/tb_categoria.dart';
import 'package:mercado_list/core/utils/data_utils.dart';
import 'package:mercado_list/features/categoria/mapper/categoria_mapper.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/repository/categoria_repository.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('edição persiste apenas os campos editáveis da categoria', () async {
    final executor = _ExecutorCategoria(_mapaCategoriaPadrao());
    final repository = CategoriasRepository(
      bancoLocal: BancoLocal.instancia,
      categoriaMapper: CategoriaMapper(),
    );
    final categoria = Categoria(
      id: 1,
      titulo: 'Título indevido',
      cor: Cor.obterCor(cor: Cor.vermelho),
      ordem: 99,
      descricao: null,
      excluido: true,
      categoriaPadrao: false,
    );

    final editada = await repository.editar(
      categoria,
      databaseExecutor: executor,
    );

    expect(
      executor.ultimaAtualizacao.keys,
      unorderedEquals([
        TbCategoria.colunaCor,
        TbCategoria.colunaDescricao,
        TbCategoria.colunaDataAlteracao,
      ]),
    );
    expect(executor.ultimaAtualizacao[TbCategoria.colunaDescricao], isNull);
    expect(editada.titulo, 'Sem categoria');
    expect(editada.ordem, 1);
    expect(editada.categoriaPadrao, isTrue);
    expect(editada.excluido, isFalse);
    expect(editada.cor, Cor.obterCor(cor: Cor.vermelho));
  });
}

Map<String, Object?> _mapaCategoriaPadrao() {
  final data = DataUtils.paraPersistencia(DateTime.utc(2026, 7, 19));
  return {
    TbCategoria.colunaId: 1,
    TbCategoria.colunaTitulo: 'Sem categoria',
    TbCategoria.colunaCor: Cor.marrom.name,
    TbCategoria.colunaOrdem: 1,
    TbCategoria.colunaDescricao: 'Descrição antiga',
    TbCategoria.colunaDataCriacao: data,
    TbCategoria.colunaDataAlteracao: data,
    TbCategoria.colunaExcluido: 0,
    TbCategoria.colunaCategoriaPadrao: 1,
  };
}

class _ExecutorCategoria implements DatabaseExecutor {
  final Map<String, Object?> registro;
  Map<String, Object?> ultimaAtualizacao = {};

  _ExecutorCategoria(this.registro);

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async =>
      [Map.of(registro)];

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    ultimaAtualizacao = Map.of(values);
    registro.addAll(values);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
