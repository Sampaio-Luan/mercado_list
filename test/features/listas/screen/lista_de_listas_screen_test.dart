import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/constants/enums/tipo_visualizacao_itens.dart';
import 'package:mercado_list/core/services/preferencias_service.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/screen/itens_recorrentes_drawer.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/itens/widget/compositor_item_widget.dart';
import 'package:mercado_list/features/listas/controller/listas_controller.dart';
import 'package:mercado_list/features/listas/model/lista_com_resumo_de_itens_model.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/listas/service/listas_service.dart';
import 'package:mercado_list/features/preferencias_usuario/preferencias_provider.dart';
import 'package:mercado_list/features/principal_screen.dart';
import 'package:mercado_list/shared/widgets/dialogo/dialogo_base.dart';
import 'package:mercado_list/shared/widgets/painel_pesquisa/texto_destacado_pesquisa.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  testWidgets(
      'sugestão usa cor da categoria, desaparece e expande o formulário',
      (tester) async {
    final ambiente = await _prepararAmbiente(comSugestoes: true);
    await _montarApp(tester, ambiente);

    await tester.enterText(
      find.byKey(const ValueKey('titulo-item-rapido')),
      'arr',
    );
    await tester.pump();

    final destaque = tester.widget<TextoDestacadoPesquisa>(
      find.byType(TextoDestacadoPesquisa),
    );
    expect(destaque.estiloDestaque?.color, Colors.deepOrange);
    final botoesSegmentados = find.byWidgetPredicate(
      (widget) => widget is SegmentedButton,
    );
    expect(botoesSegmentados, findsNothing);

    await tester.tap(find.byType(TextoDestacadoPesquisa));
    await tester.pump();

    expect(find.byType(TextoDestacadoPesquisa), findsNothing);
    expect(botoesSegmentados, findsNWidgets(2));
    final titulo = tester.widget<TextField>(
      find.byKey(const ValueKey('titulo-item-rapido')),
    );
    expect(titulo.controller?.text, 'Arroz');

    await tester.enterText(
      find.byKey(const ValueKey('titulo-item-rapido')),
      'arro',
    );
    await tester.pump();
    expect(find.byType(TextoDestacadoPesquisa), findsOneWidget);
  });

  testWidgets('formulário expandido organiza controles antes do título',
      (tester) async {
    final ambiente = await _prepararAmbiente(comSugestoes: true);
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.slidersHorizontal),
    );
    await tester.pump();

    expect(find.text('Criar Item'), findsOneWidget);
    expect(find.byTooltip('Cancelar criação'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('excluir-item-em-edicao')),
      findsNothing,
    );

    final categoria = find.byKey(const ValueKey('selecionar-categoria-item'));
    final prioridade = find.byKey(const ValueKey('prioridade-neutra'));
    expect(tester.getTopLeft(categoria).dy, tester.getTopLeft(prioridade).dy);

    final seletorPrioridade = find.byKey(
      const ValueKey('prioridade-neutra'),
    );
    for (final inicial in ['N', 'B', 'M', 'A']) {
      expect(
        find.descendant(of: seletorPrioridade, matching: find.text(inicial)),
        findsOneWidget,
      );
    }
    for (final rotulo in ['Neutra', 'Baixa', 'Média', 'Alta']) {
      expect(find.text(rotulo), findsOneWidget);
    }

    final titulo = find.byKey(const ValueKey('titulo-item-rapido'));
    final observacao = find.widgetWithText(
      TextField,
      'Observação (opcional)',
    );
    expect(tester.getTopLeft(titulo).dy,
        greaterThan(tester.getTopLeft(observacao).dy));

    await tester.tap(find.text('A'));
    await tester.pump();
    expect(find.byKey(const ValueKey('prioridade-alta')), findsOneWidget);

    await tester.tap(find.byTooltip('Cancelar criação'));
    await tester.pump();
    expect(find.text('Criar Item'), findsNothing);
    expect(
      find.widgetWithIcon(IconButton, PhosphorIcons.slidersHorizontal),
      findsOneWidget,
    );
  });

  testWidgets('edição exibe cabeçalho com cancelar e excluir', (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.pencilSimple),
    );
    await tester.pump();

    expect(find.text('Editar Item'), findsOneWidget);
    expect(find.byTooltip('Cancelar edição'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('excluir-item-em-edicao')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('titulo-item-rapido')),
          )
          .controller
          ?.text,
      'Sabonete',
    );

    await tester.tap(find.byTooltip('Cancelar edição'));
    await tester.pump();
    expect(find.text('Editar Item'), findsNothing);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.pencilSimple),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('excluir-item-em-edicao')));
    await tester.pumpAndSettle();
    expect(find.text('Excluir item'), findsOneWidget);

    await tester.tap(find.text('Excluir').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(ambiente.controller.itens, isEmpty);
  });

  testWidgets('atalho expande e recolhe todas as categorias', (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    expect(
      find.widgetWithIcon(IconButton, PhosphorIcons.stack),
      findsOneWidget,
    );

    expect(find.text('Sabonete').hitTestable(), findsOneWidget);
    final recolher = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.arrowsIn),
    );
    recolher.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Sabonete').hitTestable(), findsNothing);
    final expandir = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.arrowsOut),
    );
    expandir.onPressed!();
    await tester.pumpAndSettle();

    expect(find.text('Sabonete').hitTestable(), findsOneWidget);
  });

  testWidgets('atalho ativo usa cápsula com a cor da lista e desativa ao tocar',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.funnel),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcados'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    final indicador = find.byKey(const ValueKey('acao-ativa-Filtrar'));
    expect(indicador, findsOneWidget);
    final container = tester.widget<AnimatedContainer>(indicador);
    final decoracao = container.decoration! as ShapeDecoration;
    expect(decoracao.color, Colors.indigo.withAlpha(38));
    expect(decoracao.shape, isA<StadiumBorder>());

    await tester.tap(indicador);
    await tester.pump();
    expect(ambiente.controller.filtroItens.ativo, isFalse);
    expect(indicador, findsNothing);
  });

  testWidgets('compartilhar e histórico ficam somente na AppBar',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    final appBar = find.byType(AppBar);
    expect(
      find.descendant(
        of: appBar,
        matching: find.byTooltip('Compartilhar lista'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: appBar,
        matching: find.byTooltip('Salvar no histórico'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CompositorItemWidget),
        matching: find.byIcon(PhosphorIcons.shareNetwork),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(CompositorItemWidget),
        matching: find.byIcon(PhosphorIcons.clockCounterClockwise),
      ),
      findsNothing,
    );
  });

  testWidgets('atalho alterna tabela e categorias e oculta expansão na tabela',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await ambiente.preferencias.alterarTipoVisualizacao(
      TipoVisualizacaoItens.tabela,
    );
    await _montarApp(tester, ambiente);

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Qtd. / preço'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Qtd. / preço'),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).activeColor,
        Colors.indigo);

    expect(find.byIcon(PhosphorIcons.arrowsIn), findsNothing);
    expect(find.byIcon(PhosphorIcons.arrowsOut), findsNothing);
    final tabela = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.table),
    );
    tabela.onPressed!();
    await tester.pump();

    expect(
      ambiente.preferencias.preferencias.tipoVisualizacao,
      TipoVisualizacaoItens.categorias,
    );
    expect(find.text('Sabonete').hitTestable(), findsOneWidget);

    final categorias = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.stack),
    );
    categorias.onPressed!();
    await tester.pump();
    expect(
      ambiente.preferencias.preferencias.tipoVisualizacao,
      TipoVisualizacaoItens.tabela,
    );
  });

  testWidgets('pesquisa usa Hero na AppBar, recebe foco e retorna ao atalho',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.magnifyingGlass),
    );
    await tester.pumpAndSettle();

    final campo = find.byKey(const ValueKey('pesquisa-itens'));
    expect(campo, findsOneWidget);
    expect(find.ancestor(of: campo, matching: find.byType(AppBar)),
        findsOneWidget);
    expect(
      tester.widget<TextField>(campo).focusNode?.hasFocus,
      isTrue,
    );
    expect(tester.widget<TextField>(campo).showCursor, isTrue);
    expect(ModalRoute.of(tester.element(campo))?.transitionDuration,
        const Duration(milliseconds: 650));
    expect(find.byTooltip('Limpar pesquisa'), findsNothing);
    final fechar = find.byKey(const ValueKey('fechar-modo-pesquisa'));
    expect(
      find.descendant(of: find.byType(AppBar), matching: fechar),
      findsOneWidget,
    );
    final botaoFechar = tester.widget<IconButton>(fechar);
    expect(
      botaoFechar.style?.shape?.resolve({}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      botaoFechar.style?.backgroundColor?.resolve({}),
      isNot(Colors.transparent),
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Hero && widget.tag == 'pesquisa-itens-hero',
      ),
      findsOneWidget,
    );

    await tester.enterText(campo, 'sabo');
    await tester.pump();
    expect(ambiente.controller.pesquisaItens, 'sabo');
    expect(find.byTooltip('Limpar pesquisa'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar pesquisa'));
    await tester.pump();
    expect(ambiente.controller.pesquisaItens, isEmpty);
    expect(find.byTooltip('Limpar pesquisa'), findsNothing);
    expect(tester.widget<TextField>(campo).focusNode?.hasFocus, isTrue);

    await tester.enterText(campo, 'sabo');
    await tester.pump();

    await tester.tap(fechar);
    await tester.pumpAndSettle();
    expect(campo, findsNothing);
    expect(ambiente.controller.pesquisaItens, isEmpty);
    expect(
      find.widgetWithIcon(IconButton, PhosphorIcons.magnifyingGlass),
      findsOneWidget,
    );
  });

  testWidgets('drawer direito pesquisa e alterna recorrente na lista ativa',
      (tester) async {
    final ambiente = await _prepararAmbiente(comSugestoes: true);
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.repeat),
    );
    await tester.pumpAndSettle();

    expect(find.text('Itens recorrentes'), findsOneWidget);
    final drawer = find.descendant(
      of: find.byType(ItensRecorrentesDrawer),
      matching: find.byType(Drawer),
    );
    expect(
      tester.getSize(drawer).width,
      tester.view.physicalSize.width / tester.view.devicePixelRatio * .70,
    );
    expect(find.text('Mercearia • kg'), findsOneWidget);
    expect(find.text('Sem categoria • und'), findsOneWidget);
    expect(find.textContaining('id:'), findsNothing);
    final listaRolavel =
        find.byKey(const ValueKey('lista-rolavel-itens-recorrentes'));
    final cabecalho =
        find.byKey(const ValueKey('cabecalho-fixo-itens-recorrentes'));
    expect(listaRolavel, findsOneWidget);
    expect(
      find.descendant(of: listaRolavel, matching: cabecalho),
      findsNothing,
    );
    final arrozDrawer = find.descendant(
      of: find.byType(ItensRecorrentesDrawer),
      matching: find.text('Arroz'),
    );
    expect(arrozDrawer, findsOneWidget);
    await tester.tap(arrozDrawer);
    await tester.pump();
    expect(ambiente.controller.localizarDuplicado('Arroz'), isNotNull);

    await tester.tap(arrozDrawer);
    await tester.pump();
    expect(ambiente.controller.localizarDuplicado('Arroz'), isNull);

    await tester.enterText(
      find.byKey(const ValueKey('pesquisa-itens-recorrentes')),
      'sabo',
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(ItensRecorrentesDrawer),
        matching: find.text('Sabonete'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(ItensRecorrentesDrawer),
        matching: find.text('Arroz'),
      ),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Limpar pesquisa'));
    await tester.pump();
    await tester.tap(find.text('Todas as categorias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mercearia'));
    await tester.pumpAndSettle();

    final seletor = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Mercearia'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(
      seletor.style?.backgroundColor?.resolve({}),
      Colors.deepOrange.withAlpha(34),
    );
  });

  testWidgets('teclado do drawer direito não desloca o rodapé principal',
      (tester) async {
    final ambiente = await _prepararAmbiente(comSugestoes: true);
    await _montarApp(tester, ambiente);
    addTearDown(tester.view.resetViewInsets);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.repeat),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('pesquisa-itens-recorrentes')),
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    final rodape = tester.widget<AnimatedPadding>(
      find.byKey(const ValueKey('rodape-lista-itens')),
    );
    expect((rodape.padding as EdgeInsets).bottom, 0);
  });

  testWidgets('filtros usam controles segmentados com cantos discretos',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.widgetWithIcon(IconButton, PhosphorIcons.funnel),
    );
    await tester.pumpAndSettle();

    final botoesSegmentados = find.byWidgetPredicate(
      (widget) => widget is SegmentedButton,
    );
    expect(botoesSegmentados, findsNWidgets(3));
    expect(find.byType(DropdownButtonFormField), findsNothing);
    expect(
        find.byKey(const ValueKey('selecionar-categoria-item')), findsNothing);
    expect(find.text('Todas as categorias'), findsOneWidget);
    final segmentos = tester
        .widgetList<Widget>(botoesSegmentados)
        .cast<SegmentedButton>()
        .toList();
    for (final segmentado in segmentos) {
      final forma = segmentado.style?.shape?.resolve({});
      expect(forma, isA<RoundedRectangleBorder>());
      expect(
        (forma! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(6),
      );
    }
    expect(
      segmentos.first.style?.backgroundColor?.resolve({WidgetState.selected}),
      Colors.indigo,
    );
    expect(
      segmentos.last.style?.backgroundColor?.resolve({WidgetState.selected}),
      Colors.indigo,
    );

    await tester.tap(find.text('Alta'));
    await tester.pump();
    final prioridade = tester
        .widgetList<Widget>(botoesSegmentados)
        .cast<SegmentedButton>()
        .elementAt(1);
    expect(
      prioridade.style?.backgroundColor?.resolve({WidgetState.selected}),
      Colors.red,
    );
  });

  testWidgets('separa fixadas e mantém contador grande fora do indicador',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    await _abrirDrawer(tester);

    expect(find.text('Listas fixadas'), findsOneWidget);
    expect(find.text('Outras listas'), findsOneWidget);
    expect(find.byType(ReorderableListView), findsNWidgets(2));
    expect(find.text('250/300'), findsOneWidget);
    expect(find.textContaining('salve os itens marcados'), findsOneWidget);
    final scaffoldDrawer = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffoldDrawer.resizeToAvoidBottomInset, isFalse);
    final scaffoldPrincipal =
        tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffoldPrincipal.resizeToAvoidBottomInset, isFalse);
    expect(
      find.descendant(
        of: find.byType(CircularPercentIndicator),
        matching: find.text('250/300'),
      ),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('pesquisa-listas')),
      'xyz',
    );
    await tester.pump();

    expect(
      find.text('Nenhuma lista encontrada para a pesquisa.'),
      findsOneWidget,
    );
    expect(ambiente.itensService.idsConsultados, [1]);
  });

  testWidgets('snackbar do drawer é exibido dentro de sua própria camada',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    await _abrirDrawer(tester);

    await tester.tap(find.text('Histórico de Compras'));
    await tester.pump();

    final snackbar = find.byType(SnackBar);
    expect(snackbar, findsOneWidget);
    expect(
      find.ancestor(of: snackbar, matching: find.byType(Drawer)),
      findsOneWidget,
    );
  });

  testWidgets('diálogo usa overlay raiz acima do drawer', (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    await _abrirDrawer(tester);

    await tester.tap(find.byTooltip('Ações da lista').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir').last);
    await tester.pumpAndSettle();

    final dialogo = find.byType(DialogoBase);
    expect(dialogo, findsOneWidget);
    expect(find.byType(Drawer), findsOneWidget);
    expect(
      find.ancestor(of: dialogo, matching: find.byType(Drawer)),
      findsNothing,
    );
  });

  testWidgets('lista selecionada mantém contraste no tema escuro',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente, tema: ThemeData.dark());
    await _abrirDrawer(tester);

    final drawer = find.byType(Drawer);
    final tituloFinder = find.descendant(
      of: drawer,
      matching: find.text('Farmácia'),
    );
    final titulo = tester.widget<Text>(tituloFinder);
    final contexto = tester.element(tituloFinder);

    expect(
      titulo.style?.color,
      Theme.of(contexto).colorScheme.onPrimaryContainer,
    );
  });
}

Future<_Ambiente> _prepararAmbiente({bool comSugestoes = false}) async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencias = PreferenciasProvider(
    PreferenciasService(sharedPreferences),
  );
  await preferencias.carregar();
  final itensService = _ItensServiceFake();
  final controller = ListasController(
    _ListasServiceFake(),
    itensService,
    preferencias,
    categoriasService: comSugestoes ? _CategoriasServiceFake() : null,
    itemRecorrenteService: comSugestoes ? _ItemRecorrenteServiceFake() : null,
  );
  await controller.carregar();
  return _Ambiente(
    preferencias: preferencias,
    controller: controller,
    itensService: itensService,
  );
}

Future<void> _montarApp(
  WidgetTester tester,
  _Ambiente ambiente, {
  ThemeData? tema,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ambiente.preferencias),
        ChangeNotifierProvider.value(value: ambiente.controller),
      ],
      child: MaterialApp(
        theme: tema,
        home: const PrincipalScreen(),
      ),
    ),
  );
}

Future<void> _abrirDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

class _Ambiente {
  final PreferenciasProvider preferencias;
  final ListasController controller;
  final _ItensServiceFake itensService;

  const _Ambiente({
    required this.preferencias,
    required this.controller,
    required this.itensService,
  });
}

class _ListasServiceFake implements ListasServiceContract {
  @override
  Future<List<ListaComResumoDeItens>> recuperarComResumo() async => [
        ListaComResumoDeItens(
          lista: Lista(
            id: 1,
            titulo: 'Farmácia',
            cor: Colors.indigo,
            ordem: 0,
            fixada: true,
            descricao: 'Marque os produtos conforme coloca no carrinho. '
                'Ao finalizar, salve os itens marcados no histórico.',
          ),
          quantidadeItens: 300,
          quantidadeItensMarcados: 250,
        ),
        ListaComResumoDeItens(
          lista: Lista(
            id: 2,
            titulo: 'Mercado',
            cor: Colors.green,
            ordem: 1,
          ),
          quantidadeItens: 2,
          quantidadeItensMarcados: 1,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItensServiceFake implements ItensService {
  final List<int> idsConsultados = [];
  final List<Item> _itens = [
    Item(
      id: 1,
      idLista: 1,
      idCategoria: 1,
      titulo: 'Sabonete',
      tipoMedida: TipoMedida.und,
    ),
  ];
  int _proximoId = 2;

  @override
  Future<List<Item>> buscarPorLista(
    int idLista, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    idsConsultados.add(idLista);
    return _itens.where((item) => item.idLista == idLista).toList();
  }

  @override
  Future<Item> criar(Item item) async {
    item.id = _proximoId++;
    _itens.add(item);
    return item;
  }

  @override
  Future<void> excluir(Item item) async {
    _itens.removeWhere((existente) => existente.id == item.id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CategoriasServiceFake implements CategoriasServiceContract {
  @override
  Future<List<Categoria>> recuperarTodos() async => [
        Categoria(
          id: 10,
          titulo: 'Mercearia',
          cor: Colors.deepOrange,
          ordem: 1,
        ),
        Categoria(
          id: 1,
          titulo: 'Sem categoria',
          cor: Colors.brown,
          ordem: 2,
          categoriaPadrao: true,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItemRecorrenteServiceFake implements ItemRecorrenteService {
  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => [
        ItemRecorrente(
          id: 1,
          idCategoria: 10,
          titulo: 'Arroz',
          tipoMedida: TipoMedida.kg,
        ),
        ItemRecorrente(
          id: 2,
          idCategoria: 1,
          titulo: 'Sabonete',
          tipoMedida: TipoMedida.und,
        ),
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
