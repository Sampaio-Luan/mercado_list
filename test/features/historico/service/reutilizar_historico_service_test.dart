import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/historico/model/historico_com_itens_model.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/model/item_historico_model.dart';
import 'package:mercado_list/features/historico/service/reutilizar_historico_service.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('reutiliza como pendentes e ignora títulos duplicados', () async {
    final itens = _ItensServiceFake([
      Item(
        id: 1,
        idLista: 7,
        idCategoria: 2,
        titulo: 'Café',
      ),
    ]);
    final service = ReutilizarHistoricoService(
      itens,
      _CategoriasServiceFake(),
    );

    final resultado = await service.executar(
      compra: HistoricoComItens(
        historico: Historico(
          id: 1,
          titulo: 'Compra',
          dataCompra: DateTime.utc(2026, 8, 2),
        ),
        itens: [
          ItemHistorico(
            idHistorico: 1,
            titulo: 'CAFÉ',
            tituloCategoria: 'Mercearia',
            quantidade: 1,
            preco: 1000,
            unidadeMedida: 'und',
          ),
          ItemHistorico(
            idHistorico: 1,
            titulo: 'Batata',
            tituloCategoria: 'Hortifruti',
            quantidade: 1500,
            preco: 800,
            unidadeMedida: 'kg',
          ),
        ],
      ),
      listaDestino: Lista(
        id: 7,
        titulo: 'Mercado',
        cor: Colors.green,
        ordem: 1,
      ),
    );

    expect(resultado.adicionados, 1);
    expect(resultado.ignorados, 1);
    expect(itens.criados.single.titulo, 'Batata');
    expect(itens.criados.single.obtido, isFalse);
    expect(itens.criados.single.idCategoria, 3);
  });
}

class _ItensServiceFake implements ItensServiceContract {
  _ItensServiceFake(this.existentes);

  final List<Item> existentes;
  final List<Item> criados = [];

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) async =>
      existentes.where((item) => item.idLista == idLista).toList();

  @override
  Future<Item> criar(Item item) async {
    criados.add(item);
    return item;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CategoriasServiceFake implements CategoriasServiceContract {
  @override
  Future<List<Categoria>> recuperarTodos() async => [
        Categoria(
          id: 2,
          titulo: 'Mercearia',
          cor: Colors.orange,
          ordem: 1,
        ),
        Categoria(
          id: 3,
          titulo: 'Hortifruti',
          cor: Colors.green,
          ordem: 2,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
