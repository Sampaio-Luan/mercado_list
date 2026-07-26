import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/constants/enums/tipo_visualizacao_itens.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../../shared/widgets/campos_formulario/peso_field.dart';
import '../../categoria/extensions/categorias_extension.dart';
import '../../categoria/model/categoria_model.dart';
import '../../categoria/widget/seletor_categoria.dart';
import '../../listas/model/lista_model.dart';
import '../controller/itens_controller.dart';
import '../model/filtro_itens.dart';
import '../model/item_model.dart';
import '../widget/compositor_item_widget.dart';
import '../widget/grupo_categoria_itens_widget.dart';

class ListaItensScreen extends StatefulWidget {
  final bool modoPesquisa;

  const ListaItensScreen({super.key, this.modoPesquisa = false});

  static Future<void> abrirPesquisa(BuildContext context) async {
    final controller = context.read<ItensController>();
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, _, _) => const _PesquisaItensScreen(),
        transitionsBuilder: (context, animacao, animacaoSecundaria, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animacao,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
    controller.alterarPesquisa('');
  }

  @override
  State<ListaItensScreen> createState() => _ListaItensScreenState();
}

class _ListaItensScreenState extends State<ListaItensScreen> {
  final _chaveCompositor = GlobalKey<CompositorItemState>();
  bool _categoriasExpandidas = true;
  int _versaoExpansaoCategorias = 0;
  final Map<String, bool> _expansaoPorCategoria = {};

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ItensController>();
    final lista = context.select<ItensController, Lista?>(
      (controller) => controller.listaSelecionada,
    );
    if (lista == null) {
      return const _EstadoItens(
        icone: PhosphorIcons.listPlus,
        mensagem: 'Crie ou selecione uma lista no menu lateral.',
      );
    }

    final tema = Theme.of(context);
    final drawerDireitoAberto =
        Scaffold.maybeOf(context)?.isEndDrawerOpen ?? false;
    return Column(
      children: [
        if (lista.orcamento != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: tema.colorScheme.surfaceContainer,
            child: Text(
              'Orçamento: ${MonetarioUtils.formatarIntToMoeda(lista.orcamento!)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: _ConteudoListaItens(
            categoriasExpandidas: _categoriasExpandidas,
            versaoExpansaoCategorias: _versaoExpansaoCategorias,
            expansaoPorCategoria: _expansaoPorCategoria,
            aoAlterarExpansao: (chave, expandido) {
              _expansaoPorCategoria[chave] = expandido;
            },
            aoAlterarMarcacao: (item, valor) =>
                _alterarObtido(controller, item, valor),
            aoEditar: (item) => _chaveCompositor.currentState?.editar(item),
          ),
        ),
        AnimatedPadding(
          key: const ValueKey('rodape-lista-itens'),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: drawerDireitoAberto
                ? 0
                : MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: CompositorItemWidget(
            key: _chaveCompositor,
            idLista: lista.id!,
            exibirSomenteAoEditar: widget.modoPesquisa,
            aoFiltrar: () => _exibirFiltros(controller),
            aoOrdenar: () => _exibirOrdenacao(controller),
            aoVisualizar: () => _alternarVisualizacao(controller),
            categoriasExpandidas: _categoriasExpandidas,
            aoAlternarCategorias: _alternarTodasCategorias,
            aoItensRecorrentes: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  void _alternarTodasCategorias() {
    setState(() {
      _categoriasExpandidas = !_categoriasExpandidas;
      _expansaoPorCategoria.clear();
      _versaoExpansaoCategorias++;
    });
  }

  Future<void> _alterarObtido(
    ItensController controller,
    Item item,
    bool valor,
  ) async {
    try {
      await controller.alterarObtido(item, valor);
    } catch (_) {
      if (mounted) context.mostrarErro('Não foi possível atualizar o item.');
    }
  }

  Future<void> _exibirFiltros(ItensController controller) async {
    final corLista = controller.listaSelecionada!.cor;
    final tema = Theme.of(context);
    final filtro = await showModalBottomSheet<FiltroItens>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Theme(
        data: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
            primary: corLista,
            secondary: corLista,
          ),
        ),
        child: _FiltroItensSheet(
          filtroInicial: controller.filtro,
          categorias: controller.categorias,
          corLista: corLista,
        ),
      ),
    );
    if (filtro != null) controller.alterarFiltro(filtro);
  }

  Future<void> _exibirOrdenacao(ItensController controller) async {
    final resultado = await showModalBottomSheet<(OrdenarPor, Ordem)>(
      context: context,
      useSafeArea: true,
      builder: (_) => _OrdenacaoItensSheet(
        ordenarPor: controller.ordenarPor,
        ordem: controller.ordem,
      ),
    );
    if (resultado != null) {
      controller.alterarOrdenacao(resultado.$1, resultado.$2);
    }
  }

  Future<void> _alternarVisualizacao(ItensController controller) {
    final proxima =
        controller.tipoVisualizacao == TipoVisualizacaoItens.categorias
            ? TipoVisualizacaoItens.tabela
            : TipoVisualizacaoItens.categorias;
    return controller.alterarVisualizacao(proxima);
  }
}

class _ConteudoListaItens extends StatelessWidget {
  final bool categoriasExpandidas;
  final int versaoExpansaoCategorias;
  final Map<String, bool> expansaoPorCategoria;
  final void Function(String chave, bool expandido) aoAlterarExpansao;
  final void Function(Item item, bool valor) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const _ConteudoListaItens({
    required this.categoriasExpandidas,
    required this.versaoExpansaoCategorias,
    required this.expansaoPorCategoria,
    required this.aoAlterarExpansao,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItensController>();

    return switch (controller.estado) {
      EstadoDeTela.carregando =>
        const Center(child: CircularProgressIndicator()),
      EstadoDeTela.erro => _EstadoItens(
          icone: PhosphorIcons.warningCircle,
          mensagem: 'Não foi possível carregar os itens desta lista.',
          textoAcao: 'Tentar novamente',
          aoAcionar: controller.recarregar,
        ),
      EstadoDeTela.carregadaSemDados => const ListaVazia(),
      EstadoDeTela.carregadaComDados when controller.itensVisiveis.isEmpty =>
        const _EstadoItens(
          icone: PhosphorIcons.magnifyingGlass,
          mensagem: 'Nenhum item corresponde aos filtros atuais.',
        ),
      EstadoDeTela.carregadaComDados
          when controller.tipoVisualizacao ==
              TipoVisualizacaoItens.categorias =>
        _VisualizacaoCategoriasItens(
          controller: controller,
          categoriasExpandidas: categoriasExpandidas,
          versaoExpansaoCategorias: versaoExpansaoCategorias,
          expansaoPorCategoria: expansaoPorCategoria,
          aoAlterarExpansao: aoAlterarExpansao,
          aoAlterarMarcacao: aoAlterarMarcacao,
          aoEditar: aoEditar,
        ),
      EstadoDeTela.carregadaComDados => Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: _TabelaItensCompacta(
            itens: controller.itensVisiveis,
            categorias: {
              for (final categoria in controller.categorias)
                categoria.id: categoria,
            },
            corLista: controller.listaSelecionada!.cor,
            aoAlterarMarcacao: aoAlterarMarcacao,
            aoEditar: aoEditar,
          ),
        ),
    };
  }
}

class _VisualizacaoCategoriasItens extends StatelessWidget {
  final ItensController controller;
  final bool categoriasExpandidas;
  final int versaoExpansaoCategorias;
  final Map<String, bool> expansaoPorCategoria;
  final void Function(String chave, bool expandido) aoAlterarExpansao;
  final void Function(Item item, bool valor) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const _VisualizacaoCategoriasItens({
    required this.controller,
    required this.categoriasExpandidas,
    required this.versaoExpansaoCategorias,
    required this.expansaoPorCategoria,
    required this.aoAlterarExpansao,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    final grupos = controller.categoriasComItens;

    return ListView.builder(
      key: PageStorageKey<String>(
        'rolagem-itens-lista-${controller.idListaSelecionada}',
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: grupos.length,
      itemBuilder: (context, indice) {
        final grupo = grupos[indice];
        final idCategoria = grupo.categoria.id ?? -indice - 1;
        final chaveExpansao = '${controller.idListaSelecionada}-$idCategoria';

        return GrupoCategoriaItensWidget(
          key: ValueKey(
            'categoria-$idCategoria-$versaoExpansaoCategorias',
          ),
          grupo: grupo,
          chaveEstado: 'estado-expansao-v2-lista-'
              '${controller.idListaSelecionada}-categoria-$idCategoria-'
              'versao-$versaoExpansaoCategorias',
          inicialmenteExpandido:
              expansaoPorCategoria[chaveExpansao] ?? categoriasExpandidas,
          aoAlterarExpansao: (expandido) =>
              aoAlterarExpansao(chaveExpansao, expandido),
          aoAlterarMarcacao: aoAlterarMarcacao,
          aoEditar: aoEditar,
        );
      },
    );
  }
}

class _PesquisaItensScreen extends StatefulWidget {
  const _PesquisaItensScreen();

  @override
  State<_PesquisaItensScreen> createState() => _PesquisaItensScreenState();
}

class _PesquisaItensScreenState extends State<_PesquisaItensScreen> {
  final _pesquisa = TextEditingController();
  final _foco = FocusNode();
  Animation<double>? _animacaoRota;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animacao = ModalRoute.of(context)?.animation;
    if (identical(animacao, _animacaoRota)) return;
    _animacaoRota?.removeStatusListener(_aoAlterarStatusRota);
    _animacaoRota = animacao;
    if (animacao == null || animacao.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _solicitarFoco());
    } else {
      animacao.addStatusListener(_aoAlterarStatusRota);
    }
  }

  @override
  void dispose() {
    _animacaoRota?.removeStatusListener(_aoAlterarStatusRota);
    _pesquisa.dispose();
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Hero(
          tag: 'pesquisa-itens-hero',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              key: const ValueKey('pesquisa-itens'),
              controller: _pesquisa,
              focusNode: _foco,
              showCursor: true,
              decoration: InputDecoration(
                hintText: 'Pesquisar nesta lista',
                prefixIcon: const Icon(PhosphorIcons.magnifyingGlass),
                suffixIcon: _pesquisa.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar pesquisa',
                        onPressed: _limparPesquisa,
                        icon: const Icon(PhosphorIcons.x),
                      ),
                filled: true,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (valor) {
                context.read<ItensController>().alterarPesquisa(valor);
                setState(() {});
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              key: const ValueKey('fechar-modo-pesquisa'),
              tooltip: 'Fechar pesquisa',
              onPressed: _fecharPesquisa,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(44),
                backgroundColor:
                    Theme.of(context).colorScheme.error.withAlpha(36),
                foregroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(PhosphorIcons.x),
            ),
          ),
        ],
      ),
      body: const ListaItensScreen(modoPesquisa: true),
    );
  }

  void _aoAlterarStatusRota(AnimationStatus status) {
    if (status == AnimationStatus.completed) _solicitarFoco();
  }

  void _solicitarFoco() {
    if (mounted && !_foco.hasFocus) _foco.requestFocus();
  }

  void _limparPesquisa() {
    _pesquisa.clear();
    context.read<ItensController>().alterarPesquisa('');
    setState(() {});
    _solicitarFoco();
  }

  void _fecharPesquisa() {
    _foco.unfocus();
    Navigator.pop(context);
  }
}

class _TabelaItensCompacta extends StatelessWidget {
  final List<Item> itens;
  final Map<int?, Categoria> categorias;
  final Color corLista;
  final void Function(Item item, bool marcado) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const _TabelaItensCompacta({
    required this.itens,
    required this.categorias,
    required this.corLista,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        final mostrarTotalSeparado = restricoes.maxWidth >= 430;
        return Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Expanded(
                    flex: 5,
                    child: Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Qtd. / preço',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (mostrarTotalSeparado)
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Total',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 0, thickness: .5),
            Expanded(
              child: ListView.separated(
                itemCount: itens.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 0, thickness: .5),
                itemBuilder: (context, indice) {
                  final item = itens[indice];
                  final categoria = categorias[item.idCategoria];
                  final total = item.valorTotal;
                  return Material(
                    color: item.obtido
                        ? corLista.withAlpha(24)
                        : Colors.transparent,
                    child: InkWell(
                      onTap: () => aoAlterarMarcacao(item, !item.obtido),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              color: _corPrioridadeTabela(
                                context,
                                item.prioridade,
                              ),
                            ),
                            SizedBox(
                              width: 45,
                              child: Checkbox(
                                value: item.obtido,
                                activeColor: corLista,
                                side: BorderSide(color: corLista, width: 2),
                                checkColor:
                                    ThemeData.estimateBrightnessForColor(
                                              corLista,
                                            ) ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                onChanged: (valor) => aoAlterarMarcacao(
                                  item,
                                  valor ?? false,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin:
                                              const EdgeInsets.only(right: 4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: categoria?.cor ??
                                                Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            categoria?.titulo ??
                                                'Sem categoria',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Opacity(
                                    opacity: .6,
                                    child: Text(_quantidadeTabela(item)),
                                  ),
                                  Opacity(
                                    opacity: .6,
                                    child: Text(
                                      item.preco == null
                                          ? 'Sem preço'
                                          : MonetarioUtils.formatarIntToMoeda(
                                              item.preco!,
                                            ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ),
                                  if (!mostrarTotalSeparado && total != null)
                                    Opacity(
                                      opacity: .9,
                                      child: Text(
                                        MonetarioUtils.formatarIntToMoeda(
                                          total,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (mostrarTotalSeparado)
                              Expanded(
                                flex: 2,
                                child: Opacity(
                                  opacity: .9,
                                  child: Text(
                                    total == null
                                        ? '—'
                                        : MonetarioUtils.formatarIntToMoeda(
                                            total,
                                          ),
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 48,
                              child: IconButton(
                                tooltip: 'Editar item',
                                onPressed: () => aoEditar(item),
                                icon: Icon(
                                  PhosphorIcons.pencilSimple,
                                  size: 20,
                                  color: corLista,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static String _quantidadeTabela(Item item) {
    final quantidade = item.quantidade;
    if (quantidade == null) return '—';
    return item.tipoMedida == TipoMedida.kg
        ? '${PesoInputFormatter.formatarGramas(quantidade)} kg'
        : '$quantidade und';
  }

  static Color _corPrioridadeTabela(
    BuildContext context,
    Prioridade prioridade,
  ) =>
      switch (prioridade) {
        Prioridade.neutra => Theme.of(context).colorScheme.outlineVariant,
        Prioridade.baixa => Colors.green,
        Prioridade.media => Colors.orange,
        Prioridade.alta => Theme.of(context).colorScheme.error,
      };
}

class _FiltroItensSheet extends StatefulWidget {
  final FiltroItens filtroInicial;
  final List<Categoria> categorias;
  final Color corLista;
  const _FiltroItensSheet(
      {required this.filtroInicial,
      required this.categorias,
      required this.corLista});

  @override
  State<_FiltroItensSheet> createState() => _FiltroItensSheetState();
}

class _FiltroItensSheetState extends State<_FiltroItensSheet> {
  late SituacaoItem situacao = widget.filtroInicial.situacao;
  late int? idCategoria = widget.filtroInicial.idCategoria;
  late Prioridade? prioridade = widget.filtroInicial.prioridade;
  late bool? possuiPreco = widget.filtroInicial.possuiPreco;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text('Filtrar itens', style: Theme.of(context).textTheme.titleLarge),
          SegmentedButton<SituacaoItem>(
            segments: const [
              ButtonSegment(value: SituacaoItem.todos, label: Text('Todos')),
              ButtonSegment(
                  value: SituacaoItem.pendentes, label: Text('Pendentes')),
              ButtonSegment(
                  value: SituacaoItem.marcados, label: Text('Marcados')),
            ],
            selected: {situacao},
            style: _estiloSegmentado(corSelecionada: widget.corLista),
            onSelectionChanged: (valor) =>
                setState(() => situacao = valor.first),
          ),
          OutlinedButton.icon(
            onPressed: _selecionarCategoria,
            icon: const Icon(PhosphorIcons.tag),
            label: Text(widget.categorias.tituloPorId(idCategoria)),
          ),
          Text('Prioridade', style: Theme.of(context).textTheme.labelLarge),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<Prioridade?>(
              segments: [
                const ButtonSegment<Prioridade?>(
                  value: null,
                  label: Text('Todas'),
                ),
                ...Prioridade.values.map(
                  (valor) => ButtonSegment<Prioridade?>(
                    value: valor,
                    label: Text(_rotuloPrioridadeFiltro(valor)),
                  ),
                ),
              ],
              selected: {prioridade},
              showSelectedIcon: false,
              style: _estiloSegmentado().copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (estados) => estados.contains(WidgetState.selected)
                      ? _corPrioridadeFiltro(prioridade, widget.corLista)
                      : null,
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (estados) => estados.contains(WidgetState.selected)
                      ? _corSobreFiltro(
                          _corPrioridadeFiltro(prioridade, widget.corLista),
                        )
                      : null,
                ),
              ),
              onSelectionChanged: (valor) =>
                  setState(() => prioridade = valor.first),
            ),
          ),
          Text('Preço', style: Theme.of(context).textTheme.labelLarge),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool?>(
              segments: const [
                ButtonSegment<bool?>(value: null, label: Text('Todos')),
                ButtonSegment<bool?>(value: true, label: Text('Com preço')),
                ButtonSegment<bool?>(value: false, label: Text('Sem preço')),
              ],
              selected: {possuiPreco},
              showSelectedIcon: false,
              style: _estiloSegmentado(corSelecionada: widget.corLista),
              onSelectionChanged: (valor) =>
                  setState(() => possuiPreco = valor.first),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, const FiltroItens()),
                child: const Text('Limpar'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(
                    context,
                    FiltroItens(
                      situacao: situacao,
                      idCategoria: idCategoria,
                      prioridade: prioridade,
                      possuiPreco: possuiPreco,
                    )),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarCategoria() async {
    final resultado = await SeletorCategoria.exibir(
      context,
      categorias: widget.categorias,
      idSelecionado: idCategoria,
      corDestaque: Theme.of(context).colorScheme.primary,
      permitirTodas: true,
    );
    if (resultado == null || !mounted) return;
    setState(() => idCategoria = resultado.idCategoria);
  }
}

class _OrdenacaoItensSheet extends StatefulWidget {
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  const _OrdenacaoItensSheet({required this.ordenarPor, required this.ordem});

  @override
  State<_OrdenacaoItensSheet> createState() => _OrdenacaoItensSheetState();
}

class _OrdenacaoItensSheetState extends State<_OrdenacaoItensSheet> {
  late OrdenarPor ordenarPor = widget.ordenarPor;
  late Ordem ordem = widget.ordem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text('Ordenar itens', style: Theme.of(context).textTheme.titleLarge),
          DropdownButtonFormField<OrdenarPor>(
            initialValue: ordenarPor,
            decoration: const InputDecoration(labelText: 'Ordenar por'),
            items: OrdenarPor.values
                .map((valor) => DropdownMenuItem(
                      value: valor,
                      child: Text(valor.name),
                    ))
                .toList(),
            onChanged: (valor) {
              if (valor != null) setState(() => ordenarPor = valor);
            },
          ),
          SegmentedButton<Ordem>(
            segments: const [
              ButtonSegment(value: Ordem.ascendente, label: Text('Crescente')),
              ButtonSegment(
                  value: Ordem.descendente, label: Text('Decrescente')),
            ],
            selected: {ordem},
            style: _estiloSegmentado(),
            onSelectionChanged: (valor) => setState(() => ordem = valor.first),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (ordenarPor, ordem)),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

ButtonStyle _estiloSegmentado({Color? corSelecionada}) {
  return ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    backgroundColor: corSelecionada == null
        ? null
        : WidgetStateProperty.resolveWith(
            (estados) =>
                estados.contains(WidgetState.selected) ? corSelecionada : null,
          ),
    foregroundColor: corSelecionada == null
        ? null
        : WidgetStateProperty.resolveWith(
            (estados) => estados.contains(WidgetState.selected)
                ? _corSobreFiltro(corSelecionada)
                : null,
          ),
  );
}

String _rotuloPrioridadeFiltro(Prioridade prioridade) => switch (prioridade) {
      Prioridade.neutra => 'Neutra',
      Prioridade.baixa => 'Baixa',
      Prioridade.media => 'Média',
      Prioridade.alta => 'Alta',
    };

Color _corPrioridadeFiltro(Prioridade? prioridade, Color corLista) =>
    switch (prioridade) {
      null => corLista,
      Prioridade.neutra => Colors.blueGrey,
      Prioridade.baixa => Colors.green,
      Prioridade.media => Colors.orange,
      Prioridade.alta => Colors.red,
    };

Color _corSobreFiltro(Color fundo) {
  return ThemeData.estimateBrightnessForColor(fundo) == Brightness.dark
      ? Colors.white
      : Colors.black;
}

class ListaVazia extends StatelessWidget {
  const ListaVazia({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Lottie.asset(
            'lib/assets/lottie.json',
            height: MediaQuery.sizeOf(context).height * .22,
          ),
          Text('Lista vazia', style: Theme.of(context).textTheme.headlineSmall),
          const Text('Digite o primeiro item no campo abaixo.'),
        ],
      ),
    );
  }
}

class _EstadoItens extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final String? textoAcao;
  final Future<void> Function()? aoAcionar;

  const _EstadoItens({
    required this.icone,
    required this.mensagem,
    this.textoAcao,
    this.aoAcionar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(icone, size: 48),
            Text(mensagem, textAlign: TextAlign.center),
            if (aoAcionar != null)
              OutlinedButton(
                onPressed: aoAcionar,
                child: Text(textoAcao!),
              ),
          ],
        ),
      ),
    );
  }
}
