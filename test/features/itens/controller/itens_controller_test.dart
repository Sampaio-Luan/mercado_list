import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/services/preferencias_service.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/controller/itens_controller.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/preferencias_usuario/controller/preferencias_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('sincroniza ordem das categorias sem recarregar itens', () async {
    final preferencias = await _criarPreferencias();
    final service = _ItensServiceFake([
      Item(id: 1, idLista: 1, idCategoria: 1, titulo: 'Arroz'),
      Item(id: 2, idLista: 1, idCategoria: 2, titulo: 'Banana'),
    ]);
    final controller = ItensController(service, preferencias);
    await controller.selecionarLista(_lista(1, 'Mercado'));
    var notificacoes = 0;
    controller.addListener(() => notificacoes++);

    controller.sincronizarCategorias([
      Categoria(id: 1, titulo: 'Mercearia', cor: Colors.orange, ordem: 2),
      Categoria(id: 2, titulo: 'Frutas', cor: Colors.green, ordem: 1),
    ]);

    expect(
      controller.categoriasComItens.map((grupo) => grupo.categoria.titulo),
      ['Frutas', 'Mercearia'],
    );
    expect(service.idsConsultados, [1]);
    expect(notificacoes, 1);

    controller.sincronizarCategorias(controller.categorias);
    expect(notificacoes, 1);

    controller.sincronizarCategorias([
      Categoria(id: 1, titulo: 'Mercearia', cor: Colors.orange, ordem: 1),
      Categoria(id: 2, titulo: 'Frutas', cor: Colors.green, ordem: 2),
    ]);
    expect(
      controller.categoriasComItens.map((grupo) => grupo.categoria.titulo),
      ['Mercearia', 'Frutas'],
    );
    expect(service.idsConsultados, [1]);
    expect(notificacoes, 2);
  });

  test('ignora recarga obsoleta quando a lista muda durante edição', () async {
    final preferencias = await _criarPreferencias();
    final service = _ItensServiceConcorrenciaFake();
    final controller = ItensController(service, preferencias);
    await controller.selecionarLista(_lista(1, 'Primeira'));
    service.atrasarProximaConsultaDaPrimeira = true;

    final edicao = controller.editar(service.itemPrimeira);
    await service.consultaDaPrimeiraIniciada.future;
    await controller.selecionarLista(_lista(2, 'Segunda'));
    service.concluirConsultaDaPrimeira();
    await edicao;

    expect(controller.idListaSelecionada, 2);
    expect(controller.itens.map((item) => item.id), [2]);
  });

  test('marcação pendente não altera itens da nova lista', () async {
    final preferencias = await _criarPreferencias();
    final service = _ItensServiceConcorrenciaFake();
    final controller = ItensController(service, preferencias);
    await controller.selecionarLista(_lista(1, 'Primeira'));

    final marcacao = controller.alterarObtido(service.itemPrimeira, true);
    await service.marcacaoIniciada.future;
    await controller.selecionarLista(_lista(2, 'Segunda'));
    service.concluirMarcacao();
    await marcacao;

    expect(controller.idListaSelecionada, 2);
    expect(controller.itens.map((item) => item.id), [2]);
  });
}

Future<PreferenciasProvider> _criarPreferencias() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final provider = PreferenciasProvider(PreferenciasService(prefs));
  await provider.carregar();
  return provider;
}

Lista _lista(int id, String titulo) => Lista(
      id: id,
      titulo: titulo,
      cor: Colors.indigo,
      ordem: id,
    );

class _ItensServiceFake implements ItensServiceContract {
  final List<int> idsConsultados = [];
  final List<Item> itens;

  _ItensServiceFake(this.itens);

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    idsConsultados.add(idLista);
    return itens;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItensServiceConcorrenciaFake implements ItensServiceContract {
  final itemPrimeira = Item(
    id: 1,
    idLista: 1,
    idCategoria: 1,
    titulo: 'Primeiro',
  );
  final itemSegunda = Item(
    id: 2,
    idLista: 2,
    idCategoria: 1,
    titulo: 'Segundo',
  );
  final consultaDaPrimeiraIniciada = Completer<void>();
  final marcacaoIniciada = Completer<void>();
  final _consultaDaPrimeira = Completer<List<Item>>();
  final _marcacao = Completer<Item>();
  bool atrasarProximaConsultaDaPrimeira = false;

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) {
    if (idLista == 1 && atrasarProximaConsultaDaPrimeira) {
      atrasarProximaConsultaDaPrimeira = false;
      consultaDaPrimeiraIniciada.complete();
      return _consultaDaPrimeira.future;
    }
    return Future.value([idLista == 1 ? itemPrimeira : itemSegunda]);
  }

  @override
  Future<Item> editar(Item item) async => item;

  @override
  Future<Item> alterarObtido(Item item, bool obtido) {
    marcacaoIniciada.complete();
    return _marcacao.future;
  }

  void concluirConsultaDaPrimeira() {
    _consultaDaPrimeira.complete([itemPrimeira]);
  }

  void concluirMarcacao() {
    _marcacao.complete(itemPrimeira.copia(obtido: true));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
