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

  test('versão 6 adiciona campos de listas e índices sem inserir exemplo',
      () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 5,
      novaVersao: 6,
    );

    final comandos = executor.comandos.join('\n');
    expect(comandos, contains("ADD COLUMN cor TEXT NOT NULL DEFAULT 'indigo'"));
    expect(comandos, contains('ADD COLUMN orcamento INTEGER'));
    expect(comandos, contains('ADD COLUMN ordem INTEGER NOT NULL DEFAULT 0'));
    expect(comandos, contains('ADD COLUMN fixada INTEGER NOT NULL DEFAULT 0'));
    expect(comandos, contains('CREATE INDEX idx_lista_ordenacao'));
    expect(comandos, contains('CREATE INDEX idx_item_lista'));
    expect(comandos, isNot(contains('Mensal (Exemplo)')));
  });

  test('versão 7 insere lista de exemplo e itens de forma condicional',
      () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 6,
      novaVersao: 7,
    );

    expect(executor.comandos, hasLength(2));
    expect(executor.comandos.first, contains('Mensal (Exemplo)'));
    expect(executor.comandos.first, contains('WHERE NOT EXISTS'));
    expect(executor.comandos.last, contains('produto.titulo'));
    expect(executor.comandos.last, contains('item_existente'));
    expect(executor.comandos.last, contains('lista.excluido = 0'));
    expect(executor.comandos.last, contains("'Arroz'"));
    expect(executor.comandos.last, contains("'Sabonete'"));
  });

  test('versão 8 troca dicas por produtos reais sem alterar lista editada',
      () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 7,
      novaVersao: 8,
    );

    expect(executor.comandos, hasLength(3));
    expect(executor.comandos.first, contains('UPDATE tb_lista'));
    expect(
      executor.comandos.first,
      contains('Uma lista editável com dicas para conhecer o Mercado List.'),
    );
    expect(executor.comandos.first, contains('AND excluido = 0'));
    expect(executor.comandos[1], contains('Marque os itens'));
    expect(executor.comandos.last, contains("'Leite integral'"));
    expect(executor.comandos.last, contains("'Banana'"));
  });

  test('versão 9 converte quantidades em kg para gramas', () async {
    final executor = _ExecutorGravador();

    await Migrations.executar(
      executor,
      versaoAnterior: 8,
      novaVersao: 9,
    );

    expect(executor.comandos, hasLength(2));
    expect(
      executor.comandos.first,
      contains('SET quantidade = quantidade * 1000'),
    );
    expect(
      executor.comandos.first,
      contains("WHERE unidade_medida = 'kg'"),
    );
    expect(executor.comandos.last, contains('tb_item_historico'));
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
