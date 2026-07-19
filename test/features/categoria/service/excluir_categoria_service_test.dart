import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/contracts/gerenciador_transacoes.dart';
import 'package:mercado_list/core/model/progresso_operacao.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/categoria/service/excluir_categoria_service.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('executa toda a exclusão no mesmo contexto transacional', () async {
    final executor = _ExecutorFake();
    final gerenciador = _GerenciadorFake(executor);
    final categoriaPadrao = _categoria(2, categoriaPadrao: true);
    final categorias = _CategoriasFake(categoriaPadrao);
    final itens = _ItensFake([
      ItemRecorrente(
        id: 10,
        idCategoria: 1,
        titulo: 'Detergente',
        tipoMedida: TipoMedida.und,
      ),
    ]);
    final service = ExcluirCategoriaService(
      gerenciador,
      categorias,
      itens,
    );
    final progressos = <ProgressoOperacao>[];

    final resultado = await service.executar(
      _categoria(1),
      idCategoriaPadraoEsperada: 2,
      aoProgredir: progressos.add,
    );

    expect(gerenciador.quantidadeExecucoes, 1);
    expect(categorias.executorRecebido, same(executor));
    expect(itens.executorRecebido, same(executor));
    expect(resultado.categoriaPadrao, same(categoriaPadrao));
    expect(resultado.quantidadeItensMovidos, 1);
    expect(progressos.map((progresso) => progresso.etapa), [1, 2, 3, 4]);
  });

  test('interrompe dentro da transação se a categoria padrão estiver obsoleta',
      () async {
    final categorias = _CategoriasFake(_categoria(3, categoriaPadrao: true));
    final itens = _ItensFake(const []);
    final service = ExcluirCategoriaService(
      _GerenciadorFake(_ExecutorFake()),
      categorias,
      itens,
    );

    await expectLater(
      service.executar(
        _categoria(1),
        idCategoriaPadraoEsperada: 2,
      ),
      throwsA(isA<StateError>()),
    );
    expect(itens.buscas, 0);
    expect(categorias.exclusoes, 0);
  });
}

Categoria _categoria(int id, {bool categoriaPadrao = false}) {
  return Categoria(
    id: id,
    titulo: categoriaPadrao ? 'Outros' : 'Limpeza',
    cor: Colors.indigo,
    ordem: id,
    categoriaPadrao: categoriaPadrao,
  );
}

class _GerenciadorFake implements GerenciadorTransacoes {
  final DatabaseExecutor executor;
  int quantidadeExecucoes = 0;

  _GerenciadorFake(this.executor);

  @override
  Future<T> executar<T>(
    Future<T> Function(DatabaseExecutor executor) operacao,
  ) {
    quantidadeExecucoes++;
    return operacao(executor);
  }
}

class _CategoriasFake implements CategoriasServiceContract {
  final Categoria categoriaPadrao;
  DatabaseExecutor? executorRecebido;
  int exclusoes = 0;

  _CategoriasFake(this.categoriaPadrao);

  @override
  Future<Categoria> criar(Categoria categoria) async => categoria;

  @override
  Future<Categoria> editar(Categoria categoria) async => categoria;

  @override
  Future<Categoria> prepararExclusao(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    executorRecebido = databaseExecutor;
    return categoriaPadrao;
  }

  @override
  Future<void> excluir(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    executorRecebido = databaseExecutor;
    exclusoes++;
  }

  @override
  Future<void> atualizarOrdens(List<Categoria> categorias) async {}

  @override
  Future<List<Categoria>> recuperarTodos() async => const [];
}

class _ItensFake implements ItemRecorrenteService {
  final List<ItemRecorrente> itens;
  DatabaseExecutor? executorRecebido;
  int buscas = 0;

  _ItensFake(this.itens);

  @override
  Future<ItemRecorrente> criar(ItemRecorrente item) async => item;

  @override
  Future<ItemRecorrente> editar(ItemRecorrente item) async => item;

  @override
  Future<void> excluir(int id) async {}

  @override
  Future<void> excluirItens(List<ItemRecorrente> itens) async {}

  @override
  Future<List<ItemRecorrente>> buscarPorCategoria({
    required int idCategoria,
    DatabaseExecutor? databaseExecutor,
  }) async {
    executorRecebido = databaseExecutor;
    buscas++;
    return itens;
  }

  @override
  Future<void> moverParaCategoria({
    required List<ItemRecorrente> itens,
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {
    executorRecebido = databaseExecutor;
  }

  @override
  Future<ItemRecorrente> moverItemParaCategoria({
    required ItemRecorrente item,
    required int idCategoriaDestino,
  }) async =>
      item;

  @override
  Future<List<ItemRecorrente>> moverItensParaCategoria({
    required List<ItemRecorrente> itens,
    required int idCategoriaDestino,
  }) async =>
      itens;

  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => itens;
}

class _ExecutorFake implements DatabaseExecutor {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
