import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/utils/monetario_utils.dart';
import '../model/item_model.dart';

class ItemDaListaWidget extends StatelessWidget {
  final Item item;
  final Color corCategoria;
  final Color corAcao;
  final ValueChanged<bool> aoAlterarMarcacao;
  final VoidCallback aoEditar;

  const ItemDaListaWidget({
    super.key,
    required this.item,
    required this.corCategoria,
    required this.corAcao,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corCategoriaComContraste = corCategoria.paraPrimeiroPlano(tema);
    final corAcaoComContraste = corAcao.paraPrimeiroPlano(tema);
    return Material(
      color: item.obtido ? corCategoria.withAlpha(28) : Colors.transparent,
      child: InkWell(
        onTap: () => aoAlterarMarcacao(!item.obtido),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 7, color: _corPrioridade(tema, item.prioridade)),
              Checkbox(
                value: item.obtido,
                activeColor: corCategoriaComContraste,
                side: BorderSide(color: corCategoriaComContraste, width: 2),
                checkColor: corCategoriaComContraste.corSobre,
                visualDensity: VisualDensity.compact,
                onChanged: (valor) => aoAlterarMarcacao(valor ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        item.titulo,
                        style: tema.textTheme.bodyLarge?.copyWith(
                          decoration:
                              item.obtido ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (_detalheQuantidadePreco(item) case final detalhe?)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Opacity(
                                opacity: .6,
                                child: Text(
                                  detalhe,
                                  textAlign: TextAlign.left,
                                  style: tema.textTheme.bodySmall,
                                ),
                              ),
                            ),
                            if (item.valorTotal case final total?)
                              Opacity(
                                opacity: .9,
                                child: Text(
                                  MonetarioUtils.formatarIntToMoeda(total),
                                  style: tema.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (item.observacao?.trim().isNotEmpty ?? false)
                        Text(
                          item.observacao!,
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar item',
                onPressed: aoEditar,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  PhosphorIcons.pencilSimple,
                  color: corAcaoComContraste,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _detalheQuantidadePreco(Item item) {
    final quantidade = item.quantidade;
    final preco = item.preco;
    if (quantidade == null && preco == null) return null;
    final quantidadeFormatada = quantidade == null
        ? '—'
        : item.tipoMedida == TipoMedida.kg
            ? '${(quantidade / 1000).toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')} kg'
            : '$quantidade und';
    if (preco == null) return quantidadeFormatada;
    final precoFormatado = MonetarioUtils.formatarIntToMoeda(preco);
    return '$quantidadeFormatada × $precoFormatado';
  }

  Color _corPrioridade(ThemeData tema, Prioridade prioridade) =>
      switch (prioridade) {
        Prioridade.neutra => tema.colorScheme.outlineVariant,
        Prioridade.baixa => Colors.green,
        Prioridade.media => Colors.orange,
        Prioridade.alta => tema.colorScheme.error,
      };
}
