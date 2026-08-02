import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/constants/enums/tipo_visualizacao_itens.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../../shared/widgets/campos_formulario/peso_field.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/painel_pesquisa/texto_destacado_pesquisa.dart';
import '../../categoria/extensions/categorias_extension.dart';
import '../../categoria/widget/seletor_categoria.dart';
import '../controller/itens_controller.dart';
import '../extensions/opcoes_itens_apresentacao_extension.dart';
import '../model/item_model.dart';
import '../model/sugestao_item_recorrente.dart';

class CompositorItemWidget extends StatefulWidget {
  final int idLista;
  final bool exibirSomenteAoEditar;
  final VoidCallback aoVisualizar;
  final VoidCallback aoItensRecorrentes;
  final bool categoriasExpandidas;
  final VoidCallback aoAlternarCategorias;

  const CompositorItemWidget({
    super.key,
    required this.idLista,
    this.exibirSomenteAoEditar = false,
    required this.aoVisualizar,
    required this.aoItensRecorrentes,
    required this.categoriasExpandidas,
    required this.aoAlternarCategorias,
  });

  @override
  State<CompositorItemWidget> createState() => CompositorItemState();
}

class CompositorItemState extends State<CompositorItemWidget> {
  final _titulo = TextEditingController();
  final _quantidade = TextEditingController(text: '1');
  final _preco = TextEditingController();
  final _observacao = TextEditingController();
  final _focoTitulo = FocusNode();
  TipoMedida _medida = TipoMedida.und;
  Prioridade _prioridade = Prioridade.neutra;
  int? _idCategoria;
  Item? _itemEmEdicao;
  bool _expandido = false;
  bool _salvando = false;
  bool _ocultarSugestoes = false;

  bool get editando => _itemEmEdicao != null;

  @override
  void didUpdateWidget(covariant CompositorItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idLista != widget.idLista) _limparCampos();
  }

  @override
  void dispose() {
    _titulo.dispose();
    _quantidade.dispose();
    _preco.dispose();
    _observacao.dispose();
    _focoTitulo.dispose();
    super.dispose();
  }

  void editar(Item item) {
    setState(() {
      _itemEmEdicao = item;
      _titulo.text = item.titulo;
      _medida = item.tipoMedida;
      _idCategoria = item.idCategoria;
      _prioridade = item.prioridade;
      _observacao.text = item.observacao ?? '';
      _quantidade.text = _formatarQuantidade(item.quantidade, item.tipoMedida);
      _preco.text = item.preco == null
          ? ''
          : MonetarioUtils.formatarIntToMoeda(item.preco!);
      _expandido = true;
    });
    _focoTitulo.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exibirSomenteAoEditar && !editando) {
      return const SizedBox.shrink();
    }

    final controller = context.watch<ItensController>();
    final categoriaSelecionada = controller.categorias.localizarPorId(
      _idCategoria ?? _categoriaPadrao(controller),
    );
    final resumo = controller.resumoFinanceiro;
    final sugestoes = editando || _ocultarSugestoes
        ? const <SugestaoItemRecorrente>[]
        : controller.sugerirItens(_titulo.text);
    final tema = Theme.of(context);
    final corLista = controller.listaSelecionada!.cor;
    return Material(
      elevation: 12,
      color: tema.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (resumo.possuiValor) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: .55,
                        child: Text(
                          MonetarioUtils.formatarIntToMoeda(resumo.subtotal),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text('/'),
                      ),
                      Text(
                        MonetarioUtils.formatarIntToMoeda(resumo.totalMarcado),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: .7),
                const SizedBox(height: 10),
              ],
              if (sugestoes.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 184),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sugestoes.length,
                      itemBuilder: (context, indice) {
                        final sugestao = sugestoes[indice];
                        return InkWell(
                          onTap: () => _aplicarSugestao(sugestao),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextoDestacadoPesquisa(
                                  texto: sugestao.item.titulo,
                                  textoPesquisa: _titulo.text,
                                  estiloDestaque: TextStyle(
                                    color: sugestao.categoria.cor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: sugestao.categoria.cor,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        sugestao.categoria.titulo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: tema.textTheme.labelSmall,
                                      ),
                                    ),
                                    Text(
                                      '  •  ${sugestao.item.tipoMedida.name}',
                                      style: tema.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (_expandido) ...[
                SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          key: const ValueKey('cancelar-formulario-item'),
                          tooltip:
                              editando ? 'Cancelar edição' : 'Cancelar criação',
                          onPressed: _limpar,
                          icon: Icon(PhosphorIcons.x, color: corLista),
                        ),
                      ),
                      Text(
                        editando ? 'Editar Item' : 'Criar Item',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: editando
                            ? IconButton(
                                key: const ValueKey('excluir-item-em-edicao'),
                                tooltip: 'Excluir item',
                                onPressed: _excluirItemEmEdicao,
                                style: IconButton.styleFrom(
                                  foregroundColor: tema.colorScheme.error,
                                  backgroundColor:
                                      tema.colorScheme.error.withAlpha(24),
                                ),
                                icon: const Icon(PhosphorIcons.trash),
                              )
                            : const SizedBox.square(dimension: 48),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        key: const ValueKey('selecionar-categoria-item'),
                        onPressed: () => _selecionarCategoria(controller),
                        icon: Icon(
                          PhosphorIcons.tag,
                          color: categoriaSelecionada?.cor ??
                              tema.colorScheme.primary,
                        ),
                        label: Text(
                          categoriaSelecionada?.titulo ?? 'Sem categoria',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: (categoriaSelecionada?.cor ??
                                  tema.colorScheme.surfaceContainerHighest)
                              .withAlpha(30),
                          foregroundColor: tema.colorScheme.onSurface,
                          side: BorderSide(
                            color: (categoriaSelecionada?.cor ??
                                    tema.colorScheme.outline)
                                .withAlpha(120),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 6,
                      child: _SeletorPrioridadeCompacto(
                        prioridade: _prioridade,
                        cor: _corPrioridade(_prioridade),
                        corSobre: _corSobre(_corPrioridade(_prioridade)),
                        aoAlterar: (prioridade) {
                          setState(() => _prioridade = prioridade);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: ValueKey('quantidade-${_medida.name}'),
                        controller: _quantidade,
                        keyboardType: TextInputType.number,
                        inputFormatters: _medida == TipoMedida.kg
                            ? [PesoInputFormatter()]
                            : [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: _medida == TipoMedida.kg
                              ? 'Peso (kg)'
                              : 'Quantidade',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentedButton<TipoMedida>(
                        key: ValueKey('medida-${_medida.name}'),
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: TipoMedida.und,
                            label: Text('und'),
                          ),
                          ButtonSegment(
                            value: TipoMedida.kg,
                            label: Text('kg'),
                          ),
                        ],
                        selected: {_medida},
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          minimumSize: const WidgetStatePropertyAll(
                            Size.fromHeight(48),
                          ),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (estados) => estados.contains(WidgetState.selected)
                                ? tema.colorScheme.primaryContainer
                                : null,
                          ),
                        ),
                        onSelectionChanged: (selecionados) {
                          _alterarMedida(selecionados.first);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _preco,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Preço',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _observacao,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    isDense: true,
                  ),
                  minLines: 1,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (!_expandido)
                    IconButton(
                      tooltip: 'Ampliar formulário',
                      onPressed: () => setState(() => _expandido = true),
                      icon: Icon(
                        PhosphorIcons.slidersHorizontal,
                        color: corLista,
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('titulo-item-rapido'),
                      controller: _titulo,
                      focusNode: _focoTitulo,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Título do item',
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {
                        _ocultarSugestoes = false;
                      }),
                      onSubmitted: (_) => _salvar(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _salvando ? null : _salvar,
                    style: FilledButton.styleFrom(
                      backgroundColor: corLista,
                      foregroundColor: _corSobre(corLista),
                    ),
                    child: Text(editando ? 'Salvar' : 'Enviar'),
                  ),
                ],
              ),
              if (!widget.exibirSomenteAoEditar) ...[
                const SizedBox(height: 7),
                const Divider(height: 1, thickness: .2),
                const SizedBox(height: 3),
                _BarraAcoes(
                  habilitada: controller.possuiItens,
                  todosItensMarcados: controller.todosItensMarcados,
                  alterandoMarcacaoTodos: controller.alterandoMarcacaoTodos,
                  corLista: controller.listaSelecionada!.cor,
                  visualizacao: controller.tipoVisualizacao,
                  aoVisualizar: widget.aoVisualizar,
                  aoItensRecorrentes: widget.aoItensRecorrentes,
                  categoriasExpandidas: widget.categoriasExpandidas,
                  aoAlternarCategorias: widget.aoAlternarCategorias,
                  aoAlternarMarcacaoTodos: () =>
                      _alternarMarcacaoTodos(controller),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _alternarMarcacaoTodos(ItensController controller) async {
    try {
      await controller.alternarMarcacaoTodos();
    } catch (_) {
      if (mounted) {
        context.mostrarErro('Não foi possível atualizar todos os itens.');
      }
    }
  }

  void _aplicarSugestao(SugestaoItemRecorrente sugestao) {
    final recorrente = sugestao.item;
    setState(() {
      _titulo.text = recorrente.titulo;
      _medida = recorrente.tipoMedida;
      _idCategoria = recorrente.idCategoria;
      _quantidade.text = recorrente.tipoMedida == TipoMedida.kg
          ? PesoInputFormatter.formatarGramas(1000)
          : '1';
      _ocultarSugestoes = true;
      _expandido = true;
    });
    _focoTitulo.requestFocus();
  }

  Future<void> _salvar() async {
    if (_salvando || _titulo.text.trim().isEmpty) return;
    final controller = context.read<ItensController>();
    final quantidade = _lerQuantidade();
    final preco = _lerPreco();
    final categoria = _idCategoria ?? _categoriaPadrao(controller);
    if (categoria == null) {
      context.mostrarErro('A categoria padrão não está disponível.');
      return;
    }
    setState(() => _salvando = true);
    try {
      if (editando) {
        final item = _itemEmEdicao!.copia(
          titulo: _titulo.text,
          idCategoria: categoria,
          tipoMedida: _medida,
          quantidade: quantidade,
          limparQuantidade: quantidade == null,
          preco: preco,
          limparPreco: preco == null,
          observacao: _observacao.text.trim(),
          limparObservacao: _observacao.text.trim().isEmpty,
          prioridade: _prioridade,
        );
        await controller.editar(item);
        if (mounted) context.mostrarSucesso('Item atualizado.');
      } else {
        final duplicado = controller.localizarDuplicado(_titulo.text);
        if (duplicado != null) {
          final acao = await _perguntarDuplicidade(duplicado, quantidade);
          if (!mounted || acao == null) return;
          if (acao == 'somar') {
            if (duplicado.tipoMedida != _medida) {
              context.mostrarErro(
                'A medida precisa ser igual para alterar a quantidade.',
              );
              return;
            }
            await controller.somarQuantidade(duplicado, quantidade ?? 1);
            if (!mounted) return;
            context.mostrarSucesso('Quantidade atualizada.');
            _limpar();
            return;
          }
        }
        await controller.criar(
          Item(
            idLista: controller.idListaSelecionada!,
            idCategoria: categoria,
            titulo: _titulo.text,
            tipoMedida: _medida,
            quantidade: quantidade,
            preco: preco,
            observacao: _observacao.text.trim().isEmpty
                ? null
                : _observacao.text.trim(),
            prioridade: _prioridade,
          ),
        );
        if (mounted) context.mostrarSucesso('Item adicionado.');
      }
      _limpar();
    } catch (erro) {
      if (mounted) context.mostrarErro('Não foi possível salvar: $erro');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<String?> _perguntarDuplicidade(Item item, int? quantidade) {
    final quantidadeTexto = _medida == TipoMedida.kg
        ? '${PesoInputFormatter.formatarGramas(quantidade ?? 1000)} kg'
        : '${quantidade ?? 1} und';
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Item já existe'),
        content: Text(
          '“${item.titulo}” já está nesta lista. Deseja criar outro ou '
          'somar $quantidadeTexto à quantidade atual?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'replicar'),
            child: const Text('Replicar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'somar'),
            child: const Text('Alterar quantidade'),
          ),
        ],
      ),
    );
  }

  int? _lerQuantidade() {
    final texto = _quantidade.text.trim();
    if (texto.isEmpty) return null;
    if (_medida == TipoMedida.kg) {
      return PesoInputFormatter.gramasDoTexto(texto);
    }
    return int.tryParse(texto);
  }

  int? _lerPreco() {
    final digitos = _preco.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digitos.isEmpty ? null : int.parse(digitos);
  }

  int? _categoriaPadrao(ItensController controller) {
    for (final categoria in controller.categorias) {
      if (categoria.categoriaPadrao) return categoria.id;
    }
    return controller.categorias.isEmpty ? null : controller.categorias.last.id;
  }

  String _formatarQuantidade(int? quantidade, TipoMedida medida) {
    if (quantidade == null) return '';
    if (medida == TipoMedida.und) return quantidade.toString();
    return PesoInputFormatter.formatarGramas(quantidade);
  }

  void _alterarMedida(TipoMedida medida) {
    if (medida == _medida) return;
    setState(() {
      _medida = medida;
      _quantidade.text = medida == TipoMedida.kg
          ? PesoInputFormatter.formatarGramas(1000)
          : '1';
    });
  }

  Future<void> _selecionarCategoria(ItensController controller) async {
    final resultado = await SeletorCategoria.exibir(
      context,
      categorias: controller.categorias,
      idSelecionado: _idCategoria ?? _categoriaPadrao(controller),
      corDestaque: controller.listaSelecionada!.cor,
      permitirCriar: true,
    );
    final idCategoria = resultado?.idCategoria;
    if (idCategoria != null && mounted) {
      setState(() => _idCategoria = idCategoria);
    }
  }

  Color _corPrioridade(Prioridade prioridade) => switch (prioridade) {
        Prioridade.neutra => Colors.blue,
        Prioridade.baixa => Colors.green,
        Prioridade.media => Colors.orange,
        Prioridade.alta => Colors.red,
      };

  Color _corSobre(Color fundo) {
    return ThemeData.estimateBrightnessForColor(fundo) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Future<void> _excluirItemEmEdicao() async {
    final item = _itemEmEdicao;
    if (item == null) return;
    final confirmar = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Deseja excluir “${item.titulo}” da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await context.read<ItensController>().excluir(item);
    if (!mounted) return;
    context.mostrarSucesso('Item excluído.');
    _limpar();
  }

  void _limpar() {
    if (!mounted) return;
    setState(() {
      _limparCampos();
    });
  }

  void _limparCampos() {
    _itemEmEdicao = null;
    _titulo.clear();
    _quantidade.text = '1';
    _preco.clear();
    _observacao.clear();
    _medida = TipoMedida.und;
    _prioridade = Prioridade.neutra;
    _idCategoria = null;
    _expandido = false;
    _ocultarSugestoes = false;
  }
}

class _SeletorPrioridadeCompacto extends StatelessWidget {
  final Prioridade prioridade;
  final Color cor;
  final Color corSobre;
  final ValueChanged<Prioridade> aoAlterar;

  const _SeletorPrioridadeCompacto({
    required this.prioridade,
    required this.cor,
    required this.corSobre,
    required this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<Prioridade>(
          key: ValueKey('prioridade-${prioridade.name}'),
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: Prioridade.values
              .map(
                (valor) => ButtonSegment(
                  value: valor,
                  tooltip: valor.rotulo,
                  label: Text(_inicial(valor)),
                ),
              )
              .toList(),
          selected: {prioridade},
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            tapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: WidgetStateProperty.resolveWith(
              (estados) => estados.contains(WidgetState.selected) ? cor : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (estados) =>
                  estados.contains(WidgetState.selected) ? corSobre : null,
            ),
          ),
          onSelectionChanged: (selecionados) {
            aoAlterar(selecionados.first);
          },
        ),
        const SizedBox(height: 2),
        Row(
          children: Prioridade.values
              .map(
                (valor) => Expanded(
                  child: Text(
                    valor.rotulo,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: valor == prioridade ? cor : null,
                          fontWeight: valor == prioridade
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  static String _inicial(Prioridade prioridade) => switch (prioridade) {
        Prioridade.neutra => 'N',
        Prioridade.baixa => 'B',
        Prioridade.media => 'M',
        Prioridade.alta => 'A',
      };
}

class _BarraAcoes extends StatelessWidget {
  final bool habilitada;
  final bool todosItensMarcados;
  final bool alterandoMarcacaoTodos;
  final Color corLista;
  final TipoVisualizacaoItens visualizacao;
  final bool categoriasExpandidas;
  final VoidCallback aoVisualizar;
  final VoidCallback aoItensRecorrentes;
  final VoidCallback aoAlternarCategorias;
  final VoidCallback aoAlternarMarcacaoTodos;

  const _BarraAcoes({
    required this.habilitada,
    required this.todosItensMarcados,
    required this.alterandoMarcacaoTodos,
    required this.corLista,
    required this.visualizacao,
    required this.categoriasExpandidas,
    required this.aoVisualizar,
    required this.aoItensRecorrentes,
    required this.aoAlternarCategorias,
    required this.aoAlternarMarcacaoTodos,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) => SizedBox(
        height: 48,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: restricoes.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Acao(
                  icone: todosItensMarcados
                      ? PhosphorIcons.square
                      : PhosphorIcons.checks,
                  rotulo:
                      todosItensMarcados ? 'Desmarcar todos' : 'Marcar todos',
                  corIcone: corLista,
                  onTap: habilitada && !alterandoMarcacaoTodos
                      ? aoAlternarMarcacaoTodos
                      : null,
                ),
                _Acao(
                  icone: visualizacao == TipoVisualizacaoItens.categorias
                      ? PhosphorIcons.stack
                      : PhosphorIcons.table,
                  rotulo: 'Visualização',
                  corIcone: corLista,
                  onTap: habilitada ? aoVisualizar : null,
                ),
                if (visualizacao == TipoVisualizacaoItens.categorias)
                  _Acao(
                    icone: categoriasExpandidas
                        ? PhosphorIcons.arrowsIn
                        : PhosphorIcons.arrowsOut,
                    rotulo: categoriasExpandidas
                        ? 'Recolher categorias'
                        : 'Expandir categorias',
                    corIcone: corLista,
                    onTap: habilitada ? aoAlternarCategorias : null,
                  ),
                _Acao(
                  icone: PhosphorIcons.repeat,
                  rotulo: 'Itens recorrentes',
                  corIcone: corLista,
                  onTap: aoItensRecorrentes,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Acao extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color? corIcone;
  final VoidCallback? onTap;

  const _Acao({
    required this.icone,
    required this.rotulo,
    this.corIcone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final botao = IconButton(
      tooltip: rotulo,
      onPressed: onTap,
      icon: Icon(icone, color: onTap == null ? null : corIcone),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: botao,
    );
  }
}
