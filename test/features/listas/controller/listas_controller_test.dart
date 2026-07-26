import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/services/preferencias_service.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/listas/controller/listas_controller.dart';
import 'package:mercado_list/features/listas/model/lista_com_resumo_de_itens_model.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/listas/service/listas_service.dart';
import 'package:mercado_list/features/preferencias_usuario/controller/preferencias_provider.dart';
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

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    idsConsultados.add(idLista);
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
