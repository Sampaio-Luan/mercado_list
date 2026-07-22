import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/contracts/gerenciador_transacoes.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/listas/model/lista_com_resumo_de_itens_model.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/listas/repository/lista_repository.dart';
import 'package:mercado_list/features/listas/service/listas_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('impede fixar uma quarta lista', () async {
    final repository = _ListaRepositoryFake()..quantidadeFixadas = 3;
    final service = ListasService(
      repository,
      _ItensServiceFake(),
      _GerenciadorFake(),
    );
    final lista = _lista(1, fixada: false);
    repository.persistida = lista;

    await expectLater(
      service.editar(lista.copia()..fixada = true),
      throwsA(isA<StateError>()),
    );
  });

  test('copia lista e itens desmarcados em uma transação', () async {
    final repository = _ListaRepositoryFake()
      ..persistida = _lista(1, fixada: true);
    final itens = _ItensServiceFake()
      ..itens = [
        Item(
          id: 8,
          idLista: 1,
          idCategoria: 2,
          titulo: 'Arroz',
          tipoMedida: TipoMedida.und,
          obtido: true,
        ),
      ];
    final gerenciador = _GerenciadorFake();
    final service = ListasService(repository, itens, gerenciador);

    final copia = await service.copiar(repository.persistida!);

    expect(gerenciador.execucoes, 1);
    expect(copia.titulo, 'Mensal (Cópia)');
    expect(copia.fixada, isFalse);
    expect(itens.idListaDestino, copia.id);
    expect(itens.itensCopiados.single.obtido, isFalse);
  });

  test('exclui itens antes da lista dentro da mesma transação', () async {
    final eventos = <String>[];
    final repository = _ListaRepositoryFake(eventos: eventos)
      ..persistida = _lista(1);
    final itens = _ItensServiceFake(eventos: eventos);
    final service = ListasService(repository, itens, _GerenciadorFake());

    await service.excluir(repository.persistida!);

    expect(eventos.take(2), ['itens', 'lista']);
  });
}

Lista _lista(int id, {bool fixada = false}) => Lista(
      id: id,
      titulo: 'Mensal',
      cor: Colors.indigo,
      ordem: 0,
      fixada: fixada,
    );

class _ListaRepositoryFake implements ListaRepositoryContract {
  final List<String>? eventos;
  Lista? persistida;
  int quantidadeFixadas = 0;
  int proximoId = 20;

  _ListaRepositoryFake({this.eventos});

  @override
  Future<Lista> criar(Lista lista, {DatabaseExecutor? databaseExecutor}) async {
    persistida = lista.copia()..id = proximoId++;
    return persistida!;
  }

  @override
  Future<Lista> editar(Lista lista,
      {DatabaseExecutor? databaseExecutor}) async {
    persistida = lista;
    return lista;
  }

  @override
  Future<void> excluir(int id,
      {DatabaseExecutor? databaseExecutor, DateTime? dataAlteracao}) async {
    eventos?.add('lista');
  }

  @override
  Future<Lista> recuperar(int id, {DatabaseExecutor? databaseExecutor}) async =>
      persistida!;

  @override
  Future<List<Lista>> recuperarTodos() async =>
      persistida == null ? [] : [persistida!];

  @override
  Future<List<Lista>> recuperarTodosNoExecutor(
          DatabaseExecutor executor) async =>
      const [];

  @override
  Future<List<ListaComResumoDeItens>> recuperarComResumo() async => const [];

  @override
  Future<int> contarFixadas({DatabaseExecutor? databaseExecutor}) async =>
      quantidadeFixadas;

  @override
  Future<void> atualizarOrdens(List<Lista> listas,
      {DatabaseExecutor? databaseExecutor, DateTime? dataAlteracao}) async {}
}

class _ItensServiceFake implements ItensService {
  final List<String>? eventos;
  List<Item> itens = [];
  List<Item> itensCopiados = [];
  int? idListaDestino;

  _ItensServiceFake({this.eventos});

  @override
  Future<List<Item>> buscarPorLista(int idLista,
          {DatabaseExecutor? databaseExecutor}) async =>
      itens;

  @override
  Future<List<Item>> copiarParaLista(List<Item> origem, int destino,
      {DatabaseExecutor? databaseExecutor}) async {
    idListaDestino = destino;
    itensCopiados = origem
        .map((item) => item.copia(idLista: destino, obtido: false))
        .toList();
    return itensCopiados;
  }

  @override
  Future<int> excluirPorLista(int idLista,
      {required DateTime dataAlteracao,
      DatabaseExecutor? databaseExecutor}) async {
    eventos?.add('itens');
    return itens.length;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GerenciadorFake implements GerenciadorTransacoes {
  int execucoes = 0;
  final DatabaseExecutor executor = _ExecutorFake();

  @override
  Future<T> executar<T>(
    Future<T> Function(DatabaseExecutor executor) operacao,
  ) {
    execucoes++;
    return operacao(executor);
  }
}

class _ExecutorFake implements DatabaseExecutor {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
