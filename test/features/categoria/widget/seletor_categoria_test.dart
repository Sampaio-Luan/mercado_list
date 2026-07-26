import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/categoria/controller/categorias_controller.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/service/excluir_categoria_service.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/categoria/widget/seletor_categoria.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('pesquisa e seleciona categoria em modal separado',
      (tester) async {
    ResultadoSelecaoCategoria? selecionada;
    final categorias = [
      Categoria(
        id: 1,
        titulo: 'Limpeza',
        cor: Colors.blue,
        ordem: 1,
      ),
      Categoria(
        id: 2,
        titulo: 'Hortifruti',
        cor: Colors.green,
        ordem: 2,
      ),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              selecionada = await SeletorCategoria.exibir(
                context,
                categorias: categorias,
                idSelecionado: 2,
                corDestaque: Colors.indigo,
              );
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'limp',
    );
    await tester.pump();

    expect(find.text('Limpeza'), findsOneWidget);
    expect(find.text('Hortifruti'), findsNothing);

    await tester.tap(find.text('Limpeza'));
    await tester.pumpAndSettle();
    expect(selecionada?.idCategoria, 1);
  });

  testWidgets('cria categoria sem sair do fluxo de seleção', (tester) async {
    ResultadoSelecaoCategoria? selecionada;
    final service = _CategoriasServiceFake();
    final controller = CategoriasController(
      service,
      _ItensRecorrentesVazio(),
      _ExcluirCategoriaFake(),
    );
    await controller.carregar();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  selecionada = await SeletorCategoria.exibir(
                    context,
                    categorias: controller.categoriasComItensRecorrentes
                        .map((grupo) => grupo.categoria)
                        .toList(),
                    idSelecionado: 1,
                    corDestaque: Colors.indigo,
                    permitirCriar: true,
                  );
                },
                child: const Text('Abrir criação'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir criação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Criar categoria'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Bebidas');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(selecionada?.idCategoria, 2);
    expect(
      controller.categoriasComItensRecorrentes.last.categoria.titulo,
      'Bebidas',
    );
  });

  testWidgets('distingue todas as categorias de cancelamento', (tester) async {
    ResultadoSelecaoCategoria? selecionada;
    final categorias = [
      Categoria(
        id: 1,
        titulo: 'Limpeza',
        cor: Colors.blue,
        ordem: 1,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selecionada = await SeletorCategoria.exibir(
                  context,
                  categorias: categorias,
                  permitirTodas: true,
                );
              },
              child: const Text('Abrir todas'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todas as categorias'));
    await tester.pumpAndSettle();

    expect(selecionada, isNotNull);
    expect(selecionada?.todas, isTrue);
    expect(selecionada?.idCategoria, isNull);

    await tester.tap(find.text('Abrir todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(selecionada, isNull);
  });

  testWidgets('remove categorias excluídas das opções', (tester) async {
    final categorias = [
      Categoria(
        id: 1,
        titulo: 'Origem',
        cor: Colors.blue,
        ordem: 1,
      ),
      Categoria(
        id: 2,
        titulo: 'Destino',
        cor: Colors.green,
        ordem: 2,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => SeletorCategoria.exibir(
                context,
                categorias: categorias,
                idsCategoriasExcluidas: const {1},
              ),
              child: const Text('Abrir destinos'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir destinos'));
    await tester.pumpAndSettle();

    expect(find.text('Origem'), findsNothing);
    expect(find.text('Destino'), findsOneWidget);
  });
}

class _CategoriasServiceFake implements CategoriasServiceContract {
  final List<Categoria> categorias = [
    Categoria(
      id: 1,
      titulo: 'Sem categoria',
      cor: Colors.brown,
      ordem: 1,
      categoriaPadrao: true,
    ),
  ];

  @override
  Future<List<Categoria>> recuperarTodos() async => categorias;

  @override
  Future<Categoria> criar(Categoria categoria) async {
    categoria.id = 2;
    categorias.add(categoria);
    return categoria;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItensRecorrentesVazio implements ItemRecorrenteService {
  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExcluirCategoriaFake implements ExcluirCategoriaContract {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
