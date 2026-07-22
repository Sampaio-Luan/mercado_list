import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/services/preferencias_service.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/listas/controller/listas_controller.dart';
import 'package:mercado_list/features/listas/model/lista_com_resumo_de_itens_model.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/listas/service/listas_service.dart';
import 'package:mercado_list/features/preferencias_usuario/preferencias_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('carrega itens somente da última lista aberta', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = PreferenciasProvider(PreferenciasService(prefs));
    await provider.carregar();
    await provider.alterarUltimaLista(2);
    final listas = _ListasServiceFake([
      _resumo(1, 'Primeira'),
      _resumo(2, 'Preferida'),
    ]);
    final itens = _ItensServiceFake();
    final controller = ListasController(listas, itens, provider);

    await controller.carregar();

    expect(controller.idListaSelecionada, 2);
    expect(itens.idsConsultados, [2]);
  });

  test('preferência inválida usa primeira lista e corrige valor salvo',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = PreferenciasProvider(PreferenciasService(prefs));
    await provider.carregar();
    await provider.alterarUltimaLista(99);
    final controller = ListasController(
      _ListasServiceFake([_resumo(3, 'Disponível')]),
      _ItensServiceFake(),
      provider,
    );

    await controller.carregar();

    expect(controller.idListaSelecionada, 3);
    expect(provider.preferencias.ultimaListaAberta, 3);
  });

  test('pesquisa ignora caixa e acentos sem consultar itens novamente',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = PreferenciasProvider(PreferenciasService(prefs));
    await provider.carregar();
    final itens = _ItensServiceFake();
    final controller = ListasController(
      _ListasServiceFake([
        _resumo(1, 'Farmácia'),
        _resumo(2, 'Mercado'),
      ]),
      itens,
      provider,
    );
    await controller.carregar();

    final resultado = controller.pesquisar('FARMACIA');

    expect(resultado.single.lista.titulo, 'Farmácia');
    expect(itens.idsConsultados, [1]);
  });

  test('sincroniza alterações na ordem das categorias sem recarregar itens',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = PreferenciasProvider(PreferenciasService(prefs));
    await provider.carregar();
    final itens = _ItensServiceFake([
      Item(id: 1, idLista: 1, idCategoria: 1, titulo: 'Arroz'),
      Item(id: 2, idLista: 1, idCategoria: 2, titulo: 'Banana'),
    ]);
    final controller = ListasController(
      _ListasServiceFake([_resumo(1, 'Mercado')]),
      itens,
      provider,
    );
    await controller.carregar();
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
    expect(itens.idsConsultados, [1]);
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
    expect(itens.idsConsultados, [1]);
    expect(notificacoes, 2);
  });
}

ListaComResumoDeItens _resumo(int id, String titulo) {
  return ListaComResumoDeItens(
    lista: Lista(
      id: id,
      titulo: titulo,
      cor: Colors.indigo,
      ordem: id,
    ),
  );
}

class _ListasServiceFake implements ListasServiceContract {
  final List<ListaComResumoDeItens> resumos;

  _ListasServiceFake(this.resumos);

  @override
  Future<List<ListaComResumoDeItens>> recuperarComResumo() async => resumos;

  @override
  Future<void> atualizarOrdens(List<Lista> listas) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItensServiceFake implements ItensService {
  final List<int> idsConsultados = [];
  final List<Item> itens;

  _ItensServiceFake([this.itens = const []]);

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
