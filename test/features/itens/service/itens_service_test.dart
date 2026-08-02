import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/repository/itens_repository.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('rejeita quantidade não positiva antes de persistir', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);
    final item = _item()..quantidade = 0;

    await expectLater(service.criar(item), throwsArgumentError);

    expect(repository.criacoes, 0);
  });

  test('rejeita preço negativo antes de editar', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);
    final item = _item(id: 1)..preco = -1;

    await expectLater(service.editar(item), throwsArgumentError);

    expect(repository.edicoes, 0);
  });

  test('edição exige lista e categoria válidas', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);
    final item = _item(id: 1)..idCategoria = 0;

    await expectLater(service.editar(item), throwsArgumentError);

    expect(repository.edicoes, 0);
  });

  test('normaliza título e persiste item válido', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);
    final item = _item(id: 1)..titulo = '  Arroz  ';

    final editado = await service.editar(item);

    expect(editado.titulo, 'Arroz');
    expect(item.titulo, '  Arroz  ');
    expect(repository.edicoes, 1);
  });

  test('altera a marcação da lista inteira em uma única operação', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);

    final alterados = await service.alterarObtidoPorLista(7, true);

    expect(alterados, 3);
    expect(repository.idListaMarcada, 7);
    expect(repository.valorMarcacao, isTrue);
  });

  test('rejeita lista inválida ao alterar todas as marcações', () async {
    final repository = _ItensRepositoryFake();
    final service = ItensService(repository);

    await expectLater(
      service.alterarObtidoPorLista(0, true),
      throwsArgumentError,
    );

    expect(repository.idListaMarcada, isNull);
  });
}

Item _item({int? id}) => Item(
      id: id,
      idLista: 1,
      idCategoria: 1,
      titulo: 'Item',
      quantidade: 1,
      preco: 100,
    );

class _ItensRepositoryFake implements ItensRepositoryContract {
  int criacoes = 0;
  int edicoes = 0;
  int? idListaMarcada;
  bool? valorMarcacao;

  @override
  Future<Item> criar(
    Item item, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    criacoes++;
    return item;
  }

  @override
  Future<Item> editar(Item item) async {
    edicoes++;
    return item;
  }

  @override
  Future<int> buscarIdCategoriaPadrao() async => 1;

  @override
  Future<int> alterarObtidoPorLista(
    int idLista,
    bool obtido, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    idListaMarcada = idLista;
    valorMarcacao = obtido;
    return 3;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
