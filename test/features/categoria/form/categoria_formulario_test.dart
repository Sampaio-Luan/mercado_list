import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/features/categoria/form/categoria_formulario.dart';
import 'package:mercado_list/features/categoria/controller/categorias_controller.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/categoria/service/excluir_categoria_service.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:provider/provider.dart';

void main() {
  test('confirmação de exclusão considera a quantidade de itens', () {
    expect(
      CategoriaFormulario.construirMensagemExclusao(
        tituloCategoria: 'Alimentos',
        quantidadeItens: 0,
      ),
      'Deseja excluir a categoria "Alimentos"?',
    );
    expect(
      CategoriaFormulario.construirMensagemExclusao(
        tituloCategoria: 'Alimentos',
        quantidadeItens: 1,
      ),
      '1 item será movido para a categoria padrão "Sem categoria". '
      'Deseja excluir a categoria "Alimentos"?',
    );
    expect(
      CategoriaFormulario.construirMensagemExclusao(
        tituloCategoria: 'Alimentos',
        quantidadeItens: 3,
      ),
      '3 itens serão movidos para a categoria padrão "Sem categoria". '
      'Deseja excluir a categoria "Alimentos"?',
    );
  });

  testWidgets('categoria padrão bloqueia título e permite alterar a cor', (
    tester,
  ) async {
    final categoria = Categoria(
      id: 1,
      titulo: 'Outros',
      cor: Cor.obterCor(cor: Cor.indigo),
      ordem: 1,
      categoriaPadrao: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoriaFormulario(categoria: categoria),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final campoTitulo = tester.widget<TextFormField>(
      find.byType(TextFormField),
    );
    expect(campoTitulo.enabled, isFalse);
    expect(find.text('Título da categoria padrão'), findsOneWidget);
    final apagarCategoriaPadrao = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('A categoria padrão não pode ser excluída'),
        matching: find.byType(IconButton),
      ),
    );
    expect(apagarCategoriaPadrao.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('cor-vermelho')));
    await tester.pump();

    expect(categoria.cor, Cor.obterCor(cor: Cor.indigo));
  });

  testWidgets('exclusão aparece apenas ao editar uma categoria', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CategoriaFormulario()),
      ),
    );

    expect(find.byTooltip('Excluir categoria'), findsNothing);

    final categoria = Categoria(
      id: 2,
      titulo: 'Alimentos',
      cor: Cor.obterCor(cor: Cor.laranja),
      ordem: 2,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoriaFormulario(categoria: categoria),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final apagarCategoria = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Excluir categoria'),
        matching: find.byType(IconButton),
      ),
    );
    expect(apagarCategoria.onPressed, isNotNull);
  });

  testWidgets('salvar edição usa o controller sem alterar o objeto original', (
    tester,
  ) async {
    final categoria = Categoria(
      id: 3,
      titulo: 'Alimento',
      cor: Cor.obterCor(cor: Cor.laranja),
      ordem: 1,
    );
    final service = _CategoriasServiceFormulario([categoria]);
    final controller = CategoriasController(
      service,
      _ItemRecorrenteServiceFormulario(),
      _ExcluirCategoriaFormulario(),
    );
    addTearDown(controller.dispose);
    await controller.carregar();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: Scaffold(body: CategoriaFormulario(categoria: categoria)),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Alimentos');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(service.categoriaEditada?.titulo, 'Alimentos');
    expect(categoria.titulo, 'Alimento');
    expect(
      controller.categoriasComItensRecorrentes.single.categoria.titulo,
      'Alimentos',
    );
  });

  testWidgets('cancelar descarta as alterações do formulário', (tester) async {
    final categoria = Categoria(
      id: 4,
      titulo: 'Bebida',
      cor: Cor.obterCor(cor: Cor.azul),
      ordem: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoriaFormulario(categoria: categoria)),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Bebidas');
    await tester.tap(find.byKey(const ValueKey('cor-vermelho')));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(categoria.titulo, 'Bebida');
    expect(categoria.cor, Cor.obterCor(cor: Cor.azul));
  });
}

class _CategoriasServiceFormulario implements CategoriasServiceContract {
  final List<Categoria> categorias;
  Categoria? categoriaEditada;

  _CategoriasServiceFormulario(this.categorias);

  @override
  Future<List<Categoria>> recuperarTodos() async => categorias;

  @override
  Future<Categoria> editar(Categoria categoria) async {
    categoriaEditada = categoria.copia();
    return categoriaEditada!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItemRecorrenteServiceFormulario implements ItemRecorrenteService {
  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExcluirCategoriaFormulario implements ExcluirCategoriaContract {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
