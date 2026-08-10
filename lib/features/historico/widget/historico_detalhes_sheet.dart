import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/utils/data_utils.dart';
import '../../../core/utils/monetario_utils.dart';
import '../form/item_historico_formulario.dart';
import '../model/historico_com_itens_model.dart';
import '../model/item_historico_model.dart';

typedef AoEditarItemHistorico = Future<ItemHistorico?> Function(
  ItemHistorico item,
);

class HistoricoDetalhesSheet extends StatefulWidget {
  const HistoricoDetalhesSheet({
    super.key,
    required this.compra,
    required this.operacaoEmAndamento,
    required this.aoEditar,
    required this.aoEditarItem,
    required this.aoCompartilhar,
    required this.aoReutilizar,
    required this.aoExcluir,
  });

  final HistoricoComItens compra;
  final bool operacaoEmAndamento;
  final VoidCallback aoEditar;
  final AoEditarItemHistorico aoEditarItem;
  final VoidCallback aoCompartilhar;
  final VoidCallback aoReutilizar;
  final VoidCallback aoExcluir;

  static Future<void> exibir(
    BuildContext context, {
    required HistoricoComItens compra,
    required bool operacaoEmAndamento,
    required VoidCallback aoEditar,
    required AoEditarItemHistorico aoEditarItem,
    required VoidCallback aoCompartilhar,
    required VoidCallback aoReutilizar,
    required VoidCallback aoExcluir,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => HistoricoDetalhesSheet(
        compra: compra,
        operacaoEmAndamento: operacaoEmAndamento,
        aoEditar: aoEditar,
        aoEditarItem: aoEditarItem,
        aoCompartilhar: aoCompartilhar,
        aoReutilizar: aoReutilizar,
        aoExcluir: aoExcluir,
      ),
    );
  }

  @override
  State<HistoricoDetalhesSheet> createState() => _HistoricoDetalhesSheetState();
}

class _HistoricoDetalhesSheetState extends State<HistoricoDetalhesSheet> {
  late HistoricoComItens _compra = widget.compra;
  bool _editandoItens = false;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = _compra.historico.cor.paraPrimeiroPlano(tema);
    final loja = _compra.historico.loja?.trim();
    return FractionallySizedBox(
      heightFactor: .9,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _compra.historico.titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge,
            ),
            if (loja != null && loja.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.storefront, size: 16, color: cor),
                  const SizedBox(width: 5),
                  Flexible(child: Text(loja, textAlign: TextAlign.center)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              DataUtils.formatarData(_compra.historico.dataCompra),
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall,
            ),
            if (_compra.historico.descricao case final descricao?) ...[
              const SizedBox(height: 8),
              Text(descricao, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: Icon(PhosphorIcons.notePencil, color: cor),
                  label: const Text('Editar'),
                  onPressed:
                      widget.operacaoEmAndamento ? null : widget.aoEditar,
                ),
                FilterChip(
                  selected: _editandoItens,
                  selectedColor: cor.withValues(alpha: .14),
                  checkmarkColor: cor,
                  avatar: Icon(PhosphorIcons.pencilSimple, color: cor),
                  label: const Text('Editar itens'),
                  onSelected: widget.operacaoEmAndamento
                      ? null
                      : (valor) => setState(() => _editandoItens = valor),
                ),
                ActionChip(
                  avatar: Icon(PhosphorIcons.repeat, color: cor),
                  label: const Text('Reutilizar'),
                  onPressed:
                      widget.operacaoEmAndamento ? null : widget.aoReutilizar,
                ),
                IconButton(
                  tooltip: 'Compartilhar compra',
                  onPressed:
                      _compra.itens.isEmpty ? null : widget.aoCompartilhar,
                  color: cor,
                  icon: const Icon(PhosphorIcons.shareNetwork),
                ),
                IconButton(
                  tooltip: 'Excluir compra',
                  onPressed:
                      widget.operacaoEmAndamento ? null : widget.aoExcluir,
                  color: tema.colorScheme.error,
                  icon: const Icon(PhosphorIcons.trash),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: _CupomHistorico(
                compra: _compra,
                cor: cor,
                editando: _editandoItens,
                aoEditar: (item) => _editarItem(context, item, cor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarItem(
    BuildContext context,
    ItemHistorico item,
    Color cor,
  ) async {
    final alterado = await ItemHistoricoFormulario.exibir(
      context,
      item: item,
      cor: cor,
    );
    if (alterado == null || !mounted) return;
    final salvo = await widget.aoEditarItem(alterado);
    if (salvo == null || !mounted) return;
    final itens = [..._compra.itens];
    final indice = itens.indexWhere((registro) => registro.id == salvo.id);
    if (indice < 0) return;
    itens[indice] = salvo;
    setState(() {
      _compra = HistoricoComItens(
        historico: _compra.historico,
        itens: List.unmodifiable(itens),
      );
    });
  }
}

class _CupomHistorico extends StatelessWidget {
  const _CupomHistorico({
    required this.compra,
    required this.cor,
    required this.editando,
    required this.aoEditar,
  });

  final HistoricoComItens compra;
  final Color cor;
  final bool editando;
  final ValueChanged<ItemHistorico> aoEditar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estiloCabecalho = tema.textTheme.labelMedium?.copyWith(
      fontFamily: 'monospace',
      fontWeight: FontWeight.w700,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.colorScheme.outlineVariant),
      ),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text('ITEM', style: estiloCabecalho),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'QTD. × PREÇO',
                  textAlign: TextAlign.right,
                  style: estiloCabecalho,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                child: Text(
                  'TOTAL',
                  textAlign: TextAlign.right,
                  style: estiloCabecalho,
                ),
              ),
            ],
          ),
          const Divider(),
          ...compra.itens.map(
            (item) => _LinhaCupomHistorico(
              item: item,
              cor: cor,
              editando: editando,
              aoEditar: () => aoEditar(item),
            ),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${compra.itens.length} ${compra.itens.length == 1 ? 'ITEM' : 'ITENS'}',
                  style: estiloCabecalho,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'TOTAL  ${MonetarioUtils.formatarIntToMoeda(compra.valorTotal)}',
                    maxLines: 1,
                    softWrap: false,
                    style: estiloCabecalho?.copyWith(color: cor, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinhaCupomHistorico extends StatelessWidget {
  const _LinhaCupomHistorico({
    required this.item,
    required this.cor,
    required this.editando,
    required this.aoEditar,
  });

  final ItemHistorico item;
  final Color cor;
  final bool editando;
  final VoidCallback aoEditar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
        );
    final quantidade = item.unidadeMedida == 'kg'
        ? NumberFormat('0.000', 'pt_BR').format(item.quantidade / 1000)
        : item.quantidade.toString();
    final preco = MonetarioUtils.formatarIntToMoeda(item.preco);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.titulo, style: estilo)),
              if (editando)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Editar ${item.titulo}',
                  onPressed: aoEditar,
                  color: cor,
                  iconSize: 19,
                  icon: const Icon(PhosphorIcons.pencilSimple),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$quantidade ${item.unidadeMedida} × $preco',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: estilo,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    MonetarioUtils.formatarIntToMoeda(item.valorTotal),
                    maxLines: 1,
                    softWrap: false,
                    style: estilo?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
