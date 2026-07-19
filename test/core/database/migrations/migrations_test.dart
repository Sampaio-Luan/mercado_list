import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/database/migrations/migrations.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('atualização direta da versão 1 para 3 executa migrations em ordem',
      () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 1,
      novaVersao: 3,
    );

    final comandos = executor.comandos.join('\n');
    expect(
      comandos,
      contains('ADD COLUMN categoria_padrao INTEGER NOT NULL DEFAULT 0'),
    );
    expect(executor.tabelasAtualizadas, ['tb_categoria']);
    expect(
      RegExp(r'RENAME COLUMN esta_excluido TO excluido').allMatches(comandos),
      hasLength(6),
    );
    expect(comandos, contains('RENAME COLUMN data_criacao TO dt_criacao'));
    expect(comandos, contains('RENAME COLUMN data_alteracao TO dt_alteracao'));
  });

  test('versão 4 renomeia a categoria padrão existente', () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 3,
      novaVersao: 4,
    );

    expect(executor.tabelasAtualizadas, ['tb_categoria']);
    expect(executor.valoresAtualizados, [
      {'titulo': 'Sem categoria'},
    ]);
    expect(executor.filtrosAtualizacao, ['categoria_padrao = ?']);
    expect(executor.argumentosAtualizacao, [
      [1],
    ]);
  });

  test('versão 5 protege a unicidade da categoria padrão ativa', () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 4,
      novaVersao: 5,
    );

    expect(executor.comandos, hasLength(1));
    expect(
      executor.comandos.single,
      contains('CREATE UNIQUE INDEX idx_categoria_padrao_ativa'),
    );
    expect(
      executor.comandos.single,
      contains('WHERE categoria_padrao = 1 AND excluido = 0'),
    );
  });
}

class _ExecutorGravador implements DatabaseExecutor {
  final List<String> comandos = [];
  final List<String> tabelasAtualizadas = [];
  final List<Map<String, Object?>> valoresAtualizados = [];
  final List<String?> filtrosAtualizacao = [];
  final List<List<Object?>?> argumentosAtualizacao = [];

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    comandos.add(sql.replaceAll(RegExp(r'\s+'), ' ').trim());
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    tabelasAtualizadas.add(table);
    valoresAtualizados.add(Map.of(values));
    filtrosAtualizacao.add(where);
    argumentosAtualizacao.add(whereArgs);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
