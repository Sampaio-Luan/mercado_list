import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/ordem.dart';
import 'package:mercado_list/core/constants/enums/ordenar_por.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/constants/enums/tipo_visualizacao_itens.dart';
import 'package:mercado_list/core/services/preferencias_service.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/itens/controller/itens_controller.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/compartilhamento/model/compartilhamento_model.dart';
import 'package:mercado_list/features/historico/controller/historico_controller.dart';
import 'package:mercado_list/features/historico/model/historico_com_itens_model.dart';
import 'package:mercado_list/features/historico/model/historico_model.dart';
import 'package:mercado_list/features/historico/service/historico_service.dart';
import 'package:mercado_list/features/historico/service/salvar_historico_service.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/screen/itens_recorrentes_drawer.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:mercado_list/features/itens/model/filtro_itens.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/service/itens_service.dart';
import 'package:mercado_list/features/itens/widget/barra_filtros_ordenacao_itens.dart';
import 'package:mercado_list/features/itens/widget/compositor_item_widget.dart';
import 'package:mercado_list/features/listas/controller/listas_controller.dart';
import 'package:mercado_list/features/listas/model/lista_com_resumo_de_itens_model.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';
import 'package:mercado_list/features/listas/service/listas_service.dart';
import 'package:mercado_list/features/preferencias_usuario/controller/preferencias_provider.dart';
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
    expect(ambiente.controller.itensController.itens, isEmpty);
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

  testWidgets('situações rápidas viram resumo com filtros adicionais',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    final resumo = find.byKey(const ValueKey('resumo-filtros-itens'));
    expect(resumo, findsNothing);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('situacao-itens-todos')),
          )
          .selected,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('mais-filtros-itens')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marcados').last);
    await tester.tap(find.text('Com preço'));
    await tester.tap(find.text('Alta'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Marcados / Com preço / P: Alta'), findsOneWidget);
    final chip = tester.widget<InputChip>(resumo);
    expect(chip.backgroundColor, Colors.indigo.withAlpha(28));
    expect(chip.side, BorderSide(color: Colors.indigo.withAlpha(210)));

    await tester.tap(resumo);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpar'));
    await tester.pumpAndSettle();

    expect(resumo, findsNothing);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(
      ambiente.controller.itensController.filtro.situacao,
      SituacaoItem.todos,
    );
    expect(ambiente.controller.itensController.filtro.ativo, isFalse);
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('situacao-itens-todos')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets('ações usam cor da lista e filtro e ordenação saem do rodapé',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    final barra = find.byType(BarraFiltrosOrdenacaoItens);
    final compositor = find.byType(CompositorItemWidget);
    expect(barra, findsOneWidget);
    expect(
      find.byKey(const ValueKey('divisor-filtro-ordenacao-itens')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('mais-filtros-itens')),
          )
          .style
          ?.foregroundColor
          ?.resolve({}),
      Colors.indigo,
    );
    expect(
      tester
          .widget<InputChip>(find.byKey(const ValueKey('ordenar-itens')))
          .labelStyle
          ?.color,
      Colors.indigo,
    );
    expect(
      find.descendant(
        of: compositor,
        matching: find.byIcon(PhosphorIcons.funnel),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: compositor,
        matching: find.byIcon(PhosphorIcons.sortAscending),
      ),
      findsNothing,
    );
    for (final icone in [
      PhosphorIcons.stack,
      PhosphorIcons.arrowsIn,
      PhosphorIcons.repeat,
    ]) {
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: compositor, matching: find.byIcon(icone)),
            )
            .color,
        Colors.indigo,
      );
    }
  });

  testWidgets('pesquisa, compartilhar e histórico ficam somente na AppBar',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    final appBar = find.byType(AppBar);
    expect(tester.widget<AppBar>(appBar).iconTheme?.color, Colors.indigo);
    expect(
      find.descendant(
        of: appBar,
        matching: find.byTooltip('Pesquisar itens'),
      ),
      findsOneWidget,
    );
    for (final icone in [
      PhosphorIcons.magnifyingGlass,
      PhosphorIcons.shareNetwork,
    ]) {
      expect(
        tester
            .widget<Icon>(
              find.descendant(of: appBar, matching: find.byIcon(icone)),
            )
            .color,
        Colors.indigo,
      );
    }
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
    expect(
      find.descendant(
        of: find.byType(CompositorItemWidget),
        matching: find.byIcon(PhosphorIcons.magnifyingGlass),
      ),
      findsNothing,
    );
  });

  testWidgets(
      'rodapé alterna todos e histórico habilita somente com item marcado',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    final salvarHistorico = find.ancestor(
      of: find.byTooltip('Salvar no histórico'),
      matching: find.byType(IconButton),
    );

    expect(tester.widget<IconButton>(salvarHistorico).onPressed, isNull);
    expect(find.byTooltip('Marcar todos'), findsOneWidget);

    await tester.tap(find.byTooltip('Marcar todos'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<IconButton>(salvarHistorico).onPressed,
      isNotNull,
    );
    expect(find.byTooltip('Desmarcar todos'), findsOneWidget);

    await tester.tap(find.byTooltip('Desmarcar todos'));
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(salvarHistorico).onPressed, isNull);
    expect(find.byTooltip('Marcar todos'), findsOneWidget);
  });

  testWidgets('ao salvar no histórico sugere desmarcar para reutilizar',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    await tester.tap(find.byTooltip('Marcar todos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Salvar no histórico'));
    await tester.pumpAndSettle();

    expect(find.byType(DialogoBase), findsOneWidget);
    expect(find.text('Compra salva'), findsOneWidget);
    expect(
      find.text('Deseja desmarcar os itens para reutilizar esta lista?'),
      findsOneWidget,
    );
    expect(find.text('Manter marcados'), findsOneWidget);
    expect(find.text('Desmarcar itens'), findsOneWidget);

    await tester.tap(find.text('Desmarcar itens'));
    await tester.pumpAndSettle();

    expect(ambiente.controller.itensController.possuiItensMarcados, isFalse);
    expect(find.byTooltip('Marcar todos'), findsOneWidget);
  });

  testWidgets('tabela usa cor da lista nos controles e alterna visualização',
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
    expect(
      tester.widget<Checkbox>(find.byType(Checkbox)).side,
      const BorderSide(color: Colors.indigo, width: 2),
    );
    expect(
      tester.widget<Icon>(find.byIcon(PhosphorIcons.pencilSimple)).color,
      Colors.indigo,
    );

    expect(find.byIcon(PhosphorIcons.arrowsIn), findsNothing);
    expect(find.byIcon(PhosphorIcons.arrowsOut), findsNothing);
    final tabela = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.table),
    );
    tabela.onPressed!();
    await tester.pumpAndSettle();

    expect(
      ambiente.preferencias.preferencias.tipoVisualizacao,
      TipoVisualizacaoItens.categorias,
    );
    expect(find.text('Sabonete').hitTestable(), findsOneWidget);

    final categorias = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, PhosphorIcons.stack),
    );
    categorias.onPressed!();
    await tester.pumpAndSettle();
    expect(
      ambiente.preferencias.preferencias.tipoVisualizacao,
      TipoVisualizacaoItens.tabela,
    );
  });

  testWidgets('pesquisa permite editar item e retorna à AppBar',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    final botaoPesquisa = find.descendant(
      of: find.byType(AppBar),
      matching: find.byTooltip('Pesquisar itens'),
    );
    expect(botaoPesquisa, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CompositorItemWidget),
        matching: find.byIcon(PhosphorIcons.magnifyingGlass),
      ),
      findsNothing,
    );

    await tester.tap(botaoPesquisa);
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
    expect(ambiente.controller.itensController.pesquisa, 'sabo');
    expect(find.byTooltip('Limpar pesquisa'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar pesquisa'));
    await tester.pump();
    expect(ambiente.controller.itensController.pesquisa, isEmpty);
    expect(find.byTooltip('Limpar pesquisa'), findsNothing);
    expect(tester.widget<TextField>(campo).focusNode?.hasFocus, isTrue);

    await tester.enterText(campo, 'sabo');
    await tester.pump();

    expect(find.byKey(const ValueKey('titulo-item-rapido')), findsNothing);
    await tester.tap(find.byTooltip('Editar item'));
    await tester.pump();
    expect(find.text('Editar Item'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('titulo-item-rapido')),
          )
          .controller
          ?.text,
      'Sabonete',
    );
    expect(
      find.descendant(
        of: find.byType(CompositorItemWidget),
        matching: find.byIcon(PhosphorIcons.funnel),
      ),
      findsNothing,
    );
    await tester.tap(find.byTooltip('Cancelar edição'));
    await tester.pump();
    expect(find.byKey(const ValueKey('titulo-item-rapido')), findsNothing);

    await tester.tap(fechar);
    await tester.pumpAndSettle();
    expect(campo, findsNothing);
    expect(ambiente.controller.itensController.pesquisa, isEmpty);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Pesquisar itens'),
      ),
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
    expect(
      ambiente.controller.itensController.localizarDuplicado('Arroz'),
      isNotNull,
    );

    await tester.tap(arrozDrawer);
    await tester.pump();
    expect(
      ambiente.controller.itensController.localizarDuplicado('Arroz'),
      isNull,
    );

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

  testWidgets('folha reúne todos os filtros com cor da lista', (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(
      find.byKey(const ValueKey('mais-filtros-itens')),
    );
    await tester.pumpAndSettle();

    final botoesSegmentados = find.byWidgetPredicate(
      (widget) => widget is SegmentedButton,
    );
    expect(botoesSegmentados, findsNWidgets(3));
    expect(find.byType(DropdownButtonFormField), findsNothing);
    expect(
        find.byKey(const ValueKey('selecionar-categoria-item')), findsNothing);
    expect(
      find.byKey(const ValueKey('selecionar-categoria-filtro-itens')),
      findsOneWidget,
    );
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
    expect(segmentos, hasLength(3));
    for (final segmentado in segmentos) {
      expect(
        segmentado.style?.backgroundColor?.resolve({WidgetState.selected}),
        Colors.indigo,
      );
    }

    await tester.tap(find.text('Alta'));
    await tester.pump();
    final prioridade = tester
        .widgetList<Widget>(botoesSegmentados)
        .cast<SegmentedButton>()
        .elementAt(1);
    expect(
      prioridade.style?.backgroundColor?.resolve({WidgetState.selected}),
      Colors.indigo,
    );
  });

  testWidgets('ordenação permanece na folha e destaca ação personalizada',
      (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);

    await tester.tap(find.byKey(const ValueKey('ordenar-itens')));
    await tester.pumpAndSettle();
    expect(find.text('Ordenar itens'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<OrdenarPor>), findsNothing);
    expect(
      find.byWidgetPredicate((widget) => widget is SegmentedButton),
      findsNWidgets(2),
    );
    expect(find.text('Data'), findsNothing);
    expect(find.byIcon(PhosphorIcons.sortAscending), findsAtLeastNWidgets(2));
    expect(find.byIcon(PhosphorIcons.sortDescending), findsOneWidget);

    await tester.tap(find.text('Preço'));
    await tester.tap(find.text('Decrescente'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(ambiente.controller.itensController.ordenarPor, OrdenarPor.preco);
    expect(ambiente.controller.itensController.ordem, Ordem.descendente);
    final botao = tester.widget<InputChip>(
      find.byKey(const ValueKey('ordenar-itens')),
    );
    expect(botao.backgroundColor, Colors.transparent);
    expect(botao.side, const BorderSide(color: Colors.indigo));
    expect(botao.labelStyle?.color, Colors.indigo);
    expect(find.text('Preço'), findsOneWidget);
    expect(find.byIcon(PhosphorIcons.sortDescending), findsOneWidget);
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

  testWidgets('atalho do drawer abre o histórico de compras', (tester) async {
    final ambiente = await _prepararAmbiente();
    await _montarApp(tester, ambiente);
    await _abrirDrawer(tester);

    await tester.tap(find.text('Histórico de Compras'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de compras'), findsOneWidget);
    expect(find.text('As compras salvas aparecerão aqui.'), findsOneWidget);
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
    salvarHistoricoService: _SalvarHistoricoServiceFake(),
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
        ChangeNotifierProvider<ItensController>.value(
          value: ambiente.controller.itensController,
        ),
        ChangeNotifierProvider(
          create: (_) =>
              HistoricoController(_HistoricoServiceFake())..carregar(),
        ),
      ],
      child: MaterialApp(
        theme: tema,
        home: const PrincipalScreen(),
      ),
    ),
  );
}

class _HistoricoServiceFake implements HistoricoServiceContract {
  @override
  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  ) =>
      throw UnimplementedError();

  @override
  Future<List<HistoricoComItens>> recuperarTodos() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  Future<Item> alterarObtido(Item item, bool obtido) async {
    final indice = _itens.indexWhere((existente) => existente.id == item.id);
    final alterado = item.copia(obtido: obtido);
    if (indice >= 0) _itens[indice] = alterado;
    return alterado;
  }

  @override
  Future<int> alterarObtidoPorLista(int idLista, bool obtido) async {
    var alterados = 0;
    for (var indice = 0; indice < _itens.length; indice++) {
      final item = _itens[indice];
      if (item.idLista != idLista || item.obtido == obtido) continue;
      _itens[indice] = item.copia(obtido: obtido);
      alterados++;
    }
    return alterados;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SalvarHistoricoServiceFake implements SalvarHistoricoServiceContract {
  @override
  Future<Historico> executar({
    required Lista lista,
    required Iterable<Item> itens,
    required Map<int, String> titulosCategorias,
  }) async {
    return Historico(
      id: 1,
      titulo: lista.titulo,
      dataCompra: DateTime.utc(2026, 8, 2),
    );
  }
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
