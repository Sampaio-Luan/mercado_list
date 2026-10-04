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
import '../../categoria/model/categoria_model.dart';
import '../../listas/model/lista_model.dart';
import '../controller/itens_controller.dart';
import '../model/filtro_itens.dart';
import '../model/item_model.dart';
import '../widget/barra_filtros_ordenacao_itens.dart';
import '../widget/compositor_item_widget.dart';
import '../widget/filtro_itens_sheet.dart';
import '../widget/grupo_categoria_itens_widget.dart';
import '../widget/ordenacao_itens_sheet.dart';

class ListaItensScreen extends StatefulWidget {
  final bool modoPesquisa;
  final Future<void> Function()? aoConcluirLista;

  const ListaItensScreen({
    super.key,
    this.modoPesquisa = false,
    this.aoConcluirLista,
  });

  static Future<void> abrirPesquisa(
    BuildContext context, {
    Future<void> Function()? aoConcluirLista,
  }) async {
    final controller = context.read<ItensController>();
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (_, _, _) =>
            _PesquisaItensScreen(aoConcluirLista: aoConcluirLista),
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
        Consumer<ItensController>(
          builder: (context, estado, _) => BarraFiltrosOrdenacaoItens(
            habilitada: estado.possuiItens,
            filtro: estado.filtro,
            categorias: estado.categorias,
            ordenarPor: estado.ordenarPor,
            ordem: estado.ordem,
            corLista: lista.cor,
            aoAlterarSituacao: (situacao) => estado.alterarFiltro(
              estado.filtro.copyWith(situacao: situacao),
            ),
            aoAbrirFiltros: () => _exibirFiltros(estado),
            aoLimparFiltros: () => estado.alterarFiltro(const FiltroItens()),
            aoAbrirOrdenacao: () => _exibirOrdenacao(estado),
          ),
        ),
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
            aoVisualizar: () => _alternarVisualizacao(controller),
            categoriasExpandidas: _categoriasExpandidas,
            aoAlternarCategorias: _alternarTodasCategorias,
            aoItensRecorrentes: () => Scaffold.of(context).openEndDrawer(),
            aoConcluirLista: widget.aoConcluirLista,
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
    final estavaConcluida = controller.todosItensMarcados;
    try {
      await controller.alterarObtido(item, valor);
      if (!estavaConcluida &&
          valor &&
          controller.todosItensMarcados &&
          mounted) {
        await widget.aoConcluirLista?.call();
      }
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
        child: FiltroItensSheet(
          filtroInicial: controller.filtro,
          categorias: controller.categorias,
          corLista: corLista,
        ),
      ),
    );
    if (filtro != null) controller.alterarFiltro(filtro);
  }

  Future<void> _exibirOrdenacao(ItensController controller) async {
    final corLista = controller.listaSelecionada!.cor;
    final tema = Theme.of(context);
    final resultado = await showModalBottomSheet<(OrdenarPor, Ordem)>(
      context: context,
      useSafeArea: true,
      builder: (_) => Theme(
        data: tema.copyWith(
          colorScheme: tema.colorScheme.copyWith(
            primary: corLista,
            secondary: corLista,
          ),
        ),
        child: OrdenacaoItensSheet(
          ordenarPor: controller.ordenarPor,
          ordem: controller.ordem,
          corLista: corLista,
        ),
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
      EstadoDeTela.carregando => const Center(
        child: CircularProgressIndicator(),
      ),
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
          key: ValueKey('categoria-$idCategoria-$versaoExpansaoCategorias'),
          grupo: grupo,
          chaveEstado:
              'estado-expansao-v2-lista-'
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
  const _PesquisaItensScreen({this.aoConcluirLista});

  final Future<void> Function()? aoConcluirLista;

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
    final corLista = context.select<ItensController, Color>(
      (controller) => controller.listaSelecionada!.cor,
    );
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
                        icon: Icon(PhosphorIcons.x, color: corLista),
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
                backgroundColor: corLista.withAlpha(28),
                foregroundColor: corLista,
                side: BorderSide(color: corLista.withAlpha(180)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(PhosphorIcons.x),
            ),
          ),
        ],
      ),
      body: ListaItensScreen(
        modoPesquisa: true,
        aoConcluirLista: widget.aoConcluirLista,
      ),
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
    final tema = Theme.of(context);
    return LayoutBuilder(
      builder: (context, restricoes) {
        //final mostrarTotalSeparado = restricoes.maxWidth >= 430;
        return Expanded(
          child: ListView.separated(
            itemCount: itens.length,
            separatorBuilder: (_, _) => const Divider(height: 0, thickness: .5),
            itemBuilder: (context, indice) {
              final item = itens[indice];
              final categoria = categorias[item.idCategoria];
              final total = item.valorTotal;
              final corCategoria = categoria?.cor ?? tema.colorScheme.outline;
              return Container(
                
                color: item.obtido
                    ? corLista.withAlpha(28)
                    : Colors.transparent,
                child: InkWell(
                  onTap: () => aoAlterarMarcacao(item, !item.obtido),
                  child: Row(
                    
                    children: [
                      Container(
                        height: 45,
                        width: 5,
                        color: Prioridade.obterCor(prioridade: item.prioridade),
                      ),
                      Checkbox(
                        value: item.obtido,
                        activeColor: corLista,
                        side: BorderSide(color: corLista, width: 2),
                        checkColor:
                            ThemeData.estimateBrightnessForColor(corLista) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        visualDensity: VisualDensity.compact,
                        onChanged: (valor) =>
                            aoAlterarMarcacao(item, valor ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, right: 0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: tema.textTheme.bodyLarge?.copyWith(
                                        decoration: item.obtido
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.obtido
                                            ? tema.colorScheme.onSurface
                                                  .withAlpha(150)
                                            : null,
                                      ),
                                    ),
                                  ),
                          
                                  Container(
                                    decoration: BoxDecoration(
                                      color: corCategoria.withAlpha(45),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    child: Text(
                                      categoria?.titulo ?? 'Sem categoria',
                                      maxLines: 1,
                          
                                      style: TextStyle(
                                        fontSize:
                                            (Theme.of(
                                              context,
                                            ).textTheme.labelSmall!.fontSize! -
                                            2),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${_quantidadeTabela(item)} ${(item.preco == null) ? "" : "× ${MonetarioUtils.formatarIntToMoeda(item.preco!)}"}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(190),
                                        fontSize: Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.fontSize,
                                      ),
                                    ),
                                  ),
                                  (item.preco == null)
                                      ? Text('...')
                                      : Text(
                                          MonetarioUtils.formatarIntToMoeda(
                                            total!,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: Theme.of(
                                              context,
                                            ).textTheme.labelSmall?.fontSize,
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      IconButton(
                        tooltip: 'Editar item',
                        onPressed: () => aoEditar(item),
                        icon: Icon(
                          PhosphorIcons.pencilSimple,
                          size: 20,
                          color: corLista,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
  ) => switch (prioridade) {
    Prioridade.neutra => Theme.of(context).colorScheme.outlineVariant,
    Prioridade.baixa => Colors.green,
    Prioridade.media => Colors.orange,
    Prioridade.alta => Theme.of(context).colorScheme.error,
  };
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
              OutlinedButton(onPressed: aoAcionar, child: Text(textoAcao!)),
          ],
        ),
      ),
    );
  }
}
