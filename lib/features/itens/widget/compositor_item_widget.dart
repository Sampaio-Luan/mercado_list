import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/constants/enums/tipo_visualizacao_itens.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../../shared/widgets/campos_formulario/peso_field.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/painel_pesquisa/texto_destacado_pesquisa.dart';
import '../../categoria/model/categoria_model.dart';
import '../../listas/controller/listas_controller.dart';
import '../model/filtro_itens.dart';
import '../model/item_model.dart';
import '../model/sugestao_item_recorrente.dart';

import 'seletor_categoria_modal.dart';

class CompositorItemWidget extends StatefulWidget {
  final int idLista;
  final VoidCallback aoFiltrar;
  final VoidCallback aoOrdenar;
  final VoidCallback aoPesquisar;
  final VoidCallback aoVisualizar;
  final VoidCallback aoItensRecorrentes;
  final bool pesquisaAtiva;
  final bool categoriasExpandidas;
  final VoidCallback aoAlternarCategorias;

  const CompositorItemWidget({
    super.key,
    required this.idLista,
    required this.aoFiltrar,
    required this.aoOrdenar,
    required this.aoPesquisar,
    required this.aoVisualizar,
    required this.aoItensRecorrentes,
    required this.pesquisaAtiva,
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
    final controller = context.watch<ListasController>();
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
                        MonetarioUtils.formatarIntToMoeda(
                          resumo.totalMarcado,
                        ),
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
                          icon: const Icon(PhosphorIcons.x),
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
                                key: const ValueKey(
                                  'excluir-item-em-edicao',
                                ),
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
                        onPressed: () => _selecionarCategoria(
                          controller,
                        ),
                        icon: Icon(
                          PhosphorIcons.tag,
                          color: _categoriaSelecionada(controller)?.cor ??
                              tema.colorScheme.primary,
                        ),
                        label: Text(
                          _categoriaSelecionada(controller)?.titulo ??
                              'Sem categoria',
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor:
                              (_categoriaSelecionada(controller)?.cor ??
                                      tema.colorScheme.surfaceContainerHighest)
                                  .withAlpha(30),
                          foregroundColor: tema.colorScheme.onSurface,
                          side: BorderSide(
                            color: (_categoriaSelecionada(controller)?.cor ??
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
                              value: TipoMedida.und, label: Text('und')),
                          ButtonSegment(
                              value: TipoMedida.kg, label: Text('kg')),
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
                      icon: const Icon(PhosphorIcons.slidersHorizontal),
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
             const SizedBox(height: 7),
              const Divider(height: 1, thickness: .2),
              const SizedBox(height: 3),
              _BarraAcoes(
                habilitada: controller.possuiItens,
                corLista: controller.listaSelecionada!.cor,
                filtroAtivo: controller.filtroItens.ativo,
                ordenacaoAtiva: controller.ordenarItensPor != OrdenarPor.nome ||
                    controller.ordemItens != Ordem.ascendente,
                pesquisaAtiva: widget.pesquisaAtiva,
                visualizacao: controller.tipoVisualizacaoItens,
                aoFiltrar: widget.aoFiltrar,
                aoOrdenar: widget.aoOrdenar,
                aoPesquisar: widget.aoPesquisar,
                aoVisualizar: widget.aoVisualizar,
                aoItensRecorrentes: widget.aoItensRecorrentes,
                categoriasExpandidas: widget.categoriasExpandidas,
                aoAlternarCategorias: widget.aoAlternarCategorias,
                aoLimparFiltro: () => controller.alterarFiltroItens(
                  const FiltroItens(),
                ),
                aoLimparOrdenacao: () => controller.alterarOrdenacaoItens(
                  OrdenarPor.nome,
                  Ordem.ascendente,
                ),
                aoLimparPesquisa:
                    widget.pesquisaAtiva ? widget.aoPesquisar : null,
              ),
            ],
          ),
        ),
      ),
    );
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
    final controller = context.read<ListasController>();
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
        await controller.editarItem(item);
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
        await controller.criarItem(Item(
          idLista: controller.idListaSelecionada!,
          idCategoria: categoria,
          titulo: _titulo.text,
          tipoMedida: _medida,
          quantidade: quantidade,
          preco: preco,
          observacao:
              _observacao.text.trim().isEmpty ? null : _observacao.text.trim(),
          prioridade: _prioridade,
        ));
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

  int? _categoriaPadrao(ListasController controller) {
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

  Categoria? _categoriaSelecionada(ListasController controller) {
    final id = _idCategoria ?? _categoriaPadrao(controller);
    for (final categoria in controller.categorias) {
      if (categoria.id == id) return categoria;
    }
    return null;
  }

  Future<void> _selecionarCategoria(
    ListasController controller,
  ) async {
    final id = await SeletorCategoriaModal.exibir(
      context,
      categorias: controller.categorias,
      idSelecionado: _idCategoria ?? _categoriaPadrao(controller),
      corDestaque: controller.listaSelecionada!.cor,
      permitirCriar: true,
    );
    if (id != null && mounted) setState(() => _idCategoria = id);
  }

  Color _corPrioridade(Prioridade prioridade) => switch (prioridade) {
        Prioridade.neutra => Colors.blueGrey,
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
    await context.read<ListasController>().excluirItem(item);
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
                  tooltip: _rotulo(valor),
                  label: Text(_inicial(valor)),
                ),
              )
              .toList(),
          selected: {prioridade},
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
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
                    _rotulo(valor),
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

  static String _rotulo(Prioridade prioridade) => switch (prioridade) {
        Prioridade.neutra => 'Neutra',
        Prioridade.baixa => 'Baixa',
        Prioridade.media => 'Média',
        Prioridade.alta => 'Alta',
      };
}

class _BarraAcoes extends StatelessWidget {
  final bool habilitada;
  final Color corLista;
  final bool filtroAtivo;
  final bool ordenacaoAtiva;
  final bool pesquisaAtiva;
  final TipoVisualizacaoItens visualizacao;
  final bool categoriasExpandidas;
  final VoidCallback aoFiltrar;
  final VoidCallback aoOrdenar;
  final VoidCallback aoPesquisar;
  final VoidCallback aoVisualizar;
  final VoidCallback aoItensRecorrentes;
  final VoidCallback aoLimparFiltro;
  final VoidCallback aoLimparOrdenacao;
  final VoidCallback? aoLimparPesquisa;
  final VoidCallback aoAlternarCategorias;

  const _BarraAcoes({
    required this.habilitada,
    required this.corLista,
    required this.filtroAtivo,
    required this.ordenacaoAtiva,
    required this.pesquisaAtiva,
    required this.visualizacao,
    required this.categoriasExpandidas,
    required this.aoFiltrar,
    required this.aoOrdenar,
    required this.aoPesquisar,
    required this.aoVisualizar,
    required this.aoItensRecorrentes,
    required this.aoLimparFiltro,
    required this.aoLimparOrdenacao,
    required this.aoLimparPesquisa,
    required this.aoAlternarCategorias,
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
                  icone: PhosphorIcons.funnel,
                  rotulo: 'Filtrar',
                  ativa: filtroAtivo,
                  corAtiva: corLista,
                  onTap: habilitada ? aoFiltrar : null,
                  onDesativar: filtroAtivo ? aoLimparFiltro : null,
                ),
                _Acao(
                  icone: PhosphorIcons.sortAscending,
                  rotulo: 'Ordenar',
                  ativa: ordenacaoAtiva,
                  corAtiva: corLista,
                  onTap: habilitada ? aoOrdenar : null,
                  onDesativar: ordenacaoAtiva ? aoLimparOrdenacao : null,
                ),
                _Acao(
                  icone: PhosphorIcons.magnifyingGlass,
                  rotulo: 'Pesquisar',
                  ativa: pesquisaAtiva,
                  corAtiva: corLista,
                  heroTag: 'pesquisa-itens-hero',
                  onTap: habilitada ? aoPesquisar : null,
                  onDesativar: aoLimparPesquisa,
                ),
                _Acao(
                  icone: visualizacao == TipoVisualizacaoItens.categorias
                      ? PhosphorIcons.stack
                      : PhosphorIcons.table,
                  rotulo: 'Visualização',
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
                    onTap: habilitada ? aoAlternarCategorias : null,
                  ),
                _Acao(
                  icone: PhosphorIcons.repeat,
                  rotulo: 'Itens recorrentes',
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
  final bool ativa;
  final Color? corAtiva;
  final VoidCallback? onTap;
  final VoidCallback? onDesativar;
  final String? heroTag;

  const _Acao({
    required this.icone,
    required this.rotulo,
    this.ativa = false,
    this.corAtiva,
    this.onTap,
    this.onDesativar,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    if (ativa) {
      final cor = corAtiva ?? Theme.of(context).colorScheme.primary;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Tooltip(
          message: onDesativar == null ? rotulo : 'Desativar $rotulo',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDesativar ?? onTap,
              customBorder: const StadiumBorder(),
              child: AnimatedContainer(
                key: ValueKey('acao-ativa-$rotulo'),
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 32,
                decoration: ShapeDecoration(
                  color: cor.withAlpha(38),
                  shape: StadiumBorder(
                    side: BorderSide(color: cor.withAlpha(128)),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icone, size: 21, color: cor),
              ),
            ),
          ),
        ),
      );
    }
    final botao = IconButton(
      tooltip: rotulo,
      onPressed: onTap,
      icon: Icon(icone),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: heroTag == null
          ? botao
          : Hero(
              tag: heroTag!,
              child: Material(
                type: MaterialType.transparency,
                child: botao,
              ),
            ),
    );
  }
}
