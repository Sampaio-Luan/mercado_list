import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/core/constants/enums/estado_de_tela.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/features/categoria/controller/categorias_controller.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/model/resultado_exclusao_categoria.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/categoria/service/excluir_categoria_service.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:mercado_list/core/model/progresso_operacao.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  group('CategoriasController.carregar', () {
    test('combina categorias e itens fornecidos pelos seus Services', () async {
      final categorias = [
        _categoria(id: 1, titulo: 'Limpeza'),
        _categoria(id: 2, titulo: 'Outros', categoriaPadrao: true),
      ];
      final itens = [
        _item(id: 10, idCategoria: 1, titulo: 'Detergente'),
        _item(id: 11, idCategoria: 2, titulo: 'Gelo'),
      ];
      final controller = CategoriasController(
        _CategoriasServiceFake(categorias: categorias),
        _ItemRecorrenteServiceFake(itens: itens),
        _ExcluirCategoriaFake(),
      );

      await controller.carregar();

      expect(controller.estado, EstadoDeTela.carregadaComDados);
      expect(controller.categoriasComItensRecorrentes, hasLength(2));
      expect(
        controller.categoriasComItensRecorrentes.first.itensRecorrentes,
        [itens.first],
      );
      expect(
        controller.categoriasComItensRecorrentes.last.itensRecorrentes,
        [itens.last],
      );
    });

    test('define estado de erro quando um dos Services falha', () async {
      final controller = CategoriasController(
        _CategoriasServiceFake(erro: StateError('falha simulada')),
        _ItemRecorrenteServiceFake(itens: const []),
        _ExcluirCategoriaFake(),
      );

      await controller.carregar();

      expect(controller.estado, EstadoDeTela.erro);
      expect(controller.categoriasComItensRecorrentes, isEmpty);
    });
  });

  test('sincroniza item recorrente criado pela feature de itens', () async {
    final controller = CategoriasController(
      _CategoriasServiceFake(
        categorias: [
          _categoria(id: 1, titulo: 'Limpeza'),
          _categoria(id: 2, titulo: 'Outros', categoriaPadrao: true),
        ],
      ),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();
    var notificacoes = 0;
    controller.addListener(() => notificacoes++);
    final item = _item(id: 20, idCategoria: 1, titulo: 'Sabão');

    controller.sincronizarItensRecorrentes([item]);

    expect(
      controller
          .categoriasComItensRecorrentes.first.itensRecorrentes.single.titulo,
      'Sabão',
    );
    expect(notificacoes, 1);
    controller.sincronizarItensRecorrentes([item.copia()]);
    expect(notificacoes, 1);
  });

  test('excluir atualiza a memória a partir do resultado do caso de uso',
      () async {
    final categoriaOrigem = _categoria(id: 1, titulo: 'Limpeza');
    final categoriaPadrao = _categoria(
      id: 2,
      titulo: 'Outros',
      categoriaPadrao: true,
    );
    final itemOrigem = _item(
      id: 10,
      idCategoria: 1,
      titulo: 'Detergente',
    );
    final dataAlteracao = DateTime.utc(2026, 7, 18, 15);
    final progressos = <ProgressoOperacao>[];
    final controller = CategoriasController(
      _CategoriasServiceFake(
        categorias: [categoriaOrigem, categoriaPadrao],
      ),
      _ItemRecorrenteServiceFake(itens: [itemOrigem]),
      _ExcluirCategoriaFake(
        ResultadoExclusaoCategoria(
          categoriaPadrao: categoriaPadrao,
          quantidadeItensMovidos: 1,
          dataAlteracao: dataAlteracao,
        ),
      ),
    );

    await controller.carregar();
    await controller.excluir(
      categoriaOrigem,
      aoProgredir: progressos.add,
    );

    expect(controller.categoriasComItensRecorrentes, hasLength(1));
    expect(
      controller.categoriasComItensRecorrentes.single.itensRecorrentes,
      [itemOrigem],
    );
    expect(itemOrigem.idCategoria, 2);
    expect(itemOrigem.dataAlteracao, dataAlteracao);
    expect(progressos.last.etapa, 5);
  });

  test('adiciona, edita, move e exclui um item recorrente em memória',
      () async {
    final origem = _categoria(id: 1, titulo: 'Limpeza');
    final destino = _categoria(id: 2, titulo: 'Outros');
    final controller = CategoriasController(
      _CategoriasServiceFake(categorias: [origem, destino]),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    final criado = await controller.adicionarItemRecorrente(
      ItemRecorrente(
        idCategoria: 1,
        titulo: 'Detergente',
        tipoMedida: TipoMedida.und,
      ),
    );
    expect(criado.id, 100);
    expect(
      controller.categoriasComItensRecorrentes.first.itensRecorrentes,
      [criado],
    );

    final alterado = criado.copia()..titulo = 'Detergente neutro';
    final editado = await controller.editarItemRecorrente(alterado);
    expect(
      controller
          .categoriasComItensRecorrentes.first.itensRecorrentes.single.titulo,
      'Detergente neutro',
    );

    final movido = await controller.moverItemRecorrente(editado, 2);
    expect(
      controller.categoriasComItensRecorrentes.first.itensRecorrentes,
      isEmpty,
    );
    expect(
      controller.categoriasComItensRecorrentes.last.itensRecorrentes,
      [movido],
    );

    await controller.excluirItemRecorrente(movido);
    expect(
      controller.categoriasComItensRecorrentes.last.itensRecorrentes,
      isEmpty,
    );
  });

  test('categoria padrão pode ser reordenada', () async {
    final comum = _categoria(id: 1, titulo: 'Limpeza');
    final padrao = _categoria(
      id: 2,
      titulo: 'Outros',
      categoriaPadrao: true,
    );
    final controller = CategoriasController(
      _CategoriasServiceFake(categorias: [comum, padrao]),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    await controller.reordenar(1, 0);

    expect(
      controller.categoriasComItensRecorrentes.first.categoria,
      same(padrao),
    );
    expect(padrao.ordem, 1);
    expect(comum.ordem, 2);
  });

  test('reordena uma categoria para baixo sem ajustar o destino novamente',
      () async {
    final primeira = _categoria(id: 1, titulo: 'Primeira');
    final segunda = _categoria(id: 2, titulo: 'Segunda');
    final terceira = _categoria(id: 3, titulo: 'Terceira');
    final controller = CategoriasController(
      _CategoriasServiceFake(categorias: [primeira, segunda, terceira]),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    await controller.reordenar(0, 1);

    expect(
      controller.categoriasComItensRecorrentes
          .map((grupo) => grupo.categoria.titulo),
      ['Segunda', 'Primeira', 'Terceira'],
    );
    expect(primeira.ordem, 2);
  });

  test('ordena categorias alfabeticamente ignorando acentos e caixa', () async {
    final zoologico = _categoria(id: 1, titulo: 'Zoológico');
    final alimentos = _categoria(id: 2, titulo: 'Alimentos');
    final acougue = _categoria(id: 3, titulo: 'Açougue');
    final bebidas = _categoria(id: 4, titulo: 'bebidas');
    final controller = CategoriasController(
      _CategoriasServiceFake(
        categorias: [zoologico, alimentos, acougue, bebidas],
      ),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    await controller.ordenarAlfabeticamente();

    expect(
      controller.categoriasComItensRecorrentes
          .map((grupo) => grupo.categoria.titulo),
      ['Açougue', 'Alimentos', 'bebidas', 'Zoológico'],
    );
    expect(
      controller.categoriasComItensRecorrentes
          .map((grupo) => grupo.categoria.ordem),
      [1, 2, 3, 4],
    );
  });

  test('editar categoria substitui a categoria e preserva seus itens',
      () async {
    final categoria = _categoria(id: 1, titulo: 'Limpeza');
    final item = _item(id: 10, idCategoria: 1, titulo: 'Detergente');
    final service = _CategoriasServiceFake(categorias: [categoria]);
    final controller = CategoriasController(
      service,
      _ItemRecorrenteServiceFake(itens: [item]),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    final editada = await controller.editarCategoria(
      categoria.copia()..titulo = 'Produtos de limpeza',
    );

    expect(editada.titulo, 'Produtos de limpeza');
    expect(
      controller.categoriasComItensRecorrentes.single.categoria.titulo,
      'Produtos de limpeza',
    );
    expect(
      controller.categoriasComItensRecorrentes.single.itensRecorrentes,
      [item],
    );
  });

  test('não permite duas alterações de ordem simultâneas', () async {
    final atualizacaoPendente = Completer<void>();
    final controller = CategoriasController(
      _CategoriasServiceFake(
        categorias: [
          _categoria(id: 1, titulo: 'B'),
          _categoria(id: 2, titulo: 'A'),
        ],
        atualizacaoOrdensPendente: atualizacaoPendente,
      ),
      _ItemRecorrenteServiceFake(itens: const []),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();

    final primeiraAlteracao = controller.reordenar(0, 1);
    expect(controller.alterandoOrdem, isTrue);
    await expectLater(
      controller.ordenarAlfabeticamente(),
      throwsA(isA<StateError>()),
    );

    atualizacaoPendente.complete();
    await primeiraAlteracao;
    expect(controller.alterandoOrdem, isFalse);
  });
}

Categoria _categoria({
  required int id,
  required String titulo,
  bool categoriaPadrao = false,
}) {
  return Categoria(
    id: id,
    titulo: titulo,
    cor: Cor.obterCor(cor: Cor.indigo),
    ordem: id,
    categoriaPadrao: categoriaPadrao,
  );
}

ItemRecorrente _item({
  required int id,
  required int idCategoria,
  required String titulo,
}) {
  return ItemRecorrente(
    id: id,
    idCategoria: idCategoria,
    titulo: titulo,
    tipoMedida: TipoMedida.und,
  );
}

class _CategoriasServiceFake implements CategoriasServiceContract {
  final List<Categoria> categorias;
  final Object? erro;
  final Completer<void>? atualizacaoOrdensPendente;

  _CategoriasServiceFake({
    this.categorias = const [],
    this.erro,
    this.atualizacaoOrdensPendente,
  });

  @override
  Future<Categoria> criar(Categoria categoria) async {
    return categoria..id = 99;
  }

  @override
  Future<Categoria> editar(Categoria categoria) async => categoria.copia();

  @override
  Future<List<Categoria>> recuperarTodos() async {
    if (erro != null) {
      throw erro!;
    }
    return categorias;
  }

  @override
  Future<void> atualizarOrdens(List<Categoria> categorias) async {
    await atualizacaoOrdensPendente?.future;
  }

  @override
  Future<void> excluir(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {}

  @override
  Future<Categoria> prepararExclusao(
    Categoria categoria, {
    DatabaseExecutor? databaseExecutor,
  }) {
    throw UnimplementedError();
  }
}

class _ItemRecorrenteServiceFake implements ItemRecorrenteService {
  final List<ItemRecorrente> itens;

  _ItemRecorrenteServiceFake({required this.itens});

  @override
  Future<ItemRecorrente> criar(ItemRecorrente item) async {
    return item.copia()..id = 100;
  }

  @override
  Future<ItemRecorrente> editar(ItemRecorrente item) async => item.copia();

  @override
  Future<void> excluir(int id) async {}

  @override
  Future<void> excluirItens(List<ItemRecorrente> itens) async {}

  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => itens;

  @override
  Future<List<ItemRecorrente>> buscarPorCategoria({
    required int idCategoria,
    DatabaseExecutor? databaseExecutor,
  }) async =>
      itens.where((item) => item.idCategoria == idCategoria).toList();

  @override
  Future<void> moverParaCategoria({
    required List<ItemRecorrente> itens,
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
    DateTime? dataAlteracao,
  }) async {}

  @override
  Future<ItemRecorrente> moverItemParaCategoria({
    required ItemRecorrente item,
    required int idCategoriaDestino,
  }) async {
    return item.copia()..idCategoria = idCategoriaDestino;
  }

  @override
  Future<List<ItemRecorrente>> moverItensParaCategoria({
    required List<ItemRecorrente> itens,
    required int idCategoriaDestino,
  }) async {
    return itens
        .map((item) => item.copia()..idCategoria = idCategoriaDestino)
        .toList();
  }
}

class _ExcluirCategoriaFake implements ExcluirCategoriaContract {
  final ResultadoExclusaoCategoria? resultado;

  _ExcluirCategoriaFake([this.resultado]);

  @override
  Future<ResultadoExclusaoCategoria> executar(
    Categoria categoria, {
    required int idCategoriaPadraoEsperada,
    AoProgredir? aoProgredir,
  }) async {
    if (resultado == null) {
      throw UnimplementedError();
    }
    aoProgredir?.call(
      const ProgressoOperacao(
        etapa: 4,
        total: 5,
        descricao: 'Excluindo a categoria...',
      ),
    );
    return resultado!;
  }
}
