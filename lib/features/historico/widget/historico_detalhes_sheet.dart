import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/utils/data_utils.dart';
import '../../../core/utils/monetario_utils.dart';
import '../model/historico_com_itens_model.dart';
import '../model/item_historico_model.dart';

class HistoricoDetalhesSheet extends StatelessWidget {
  const HistoricoDetalhesSheet({
    super.key,
    required this.compra,
    required this.operacaoEmAndamento,
    required this.aoEditar,
    required this.aoCompartilhar,
    required this.aoReutilizar,
    required this.aoExcluir,
  });

  final HistoricoComItens compra;
  final bool operacaoEmAndamento;
  final VoidCallback aoEditar;
  final VoidCallback aoCompartilhar;
  final VoidCallback aoReutilizar;
  final VoidCallback aoExcluir;

  static Future<void> exibir(
    BuildContext context, {
    required HistoricoComItens compra,
    required bool operacaoEmAndamento,
    required VoidCallback aoEditar,
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
        aoCompartilhar: aoCompartilhar,
        aoReutilizar: aoReutilizar,
        aoExcluir: aoExcluir,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = compra.historico.cor.paraPrimeiroPlano(tema);
    final porCategoria = <String, List<ItemHistorico>>{};
    for (final item in compra.itens) {
      porCategoria.putIfAbsent(item.tituloCategoria, () => []).add(item);
    }
    return FractionallySizedBox(
      heightFactor: .9,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              compra.historico.titulo,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              DataUtils.formatarData(compra.historico.dataCompra),
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall,
            ),
            if (compra.historico.descricao case final descricao?) ...[
              const SizedBox(height: 8),
              Text(descricao, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: Icon(Icons.edit_outlined, color: cor),
                  label: const Text('Editar'),
                  onPressed: operacaoEmAndamento ? null : aoEditar,
                ),
                ActionChip(
                  avatar: Icon(Icons.replay_outlined, color: cor),
                  label: const Text('Reutilizar'),
                  onPressed: operacaoEmAndamento ? null : aoReutilizar,
                ),
                ActionChip(
                  avatar: Icon(Icons.ios_share_outlined, color: cor),
                  label: const Text('Compartilhar'),
                  onPressed: compra.itens.isEmpty ? null : aoCompartilhar,
                ),
                ActionChip(
                  avatar:
                      Icon(Icons.delete_outline, color: tema.colorScheme.error),
                  label: const Text('Excluir'),
                  onPressed: operacaoEmAndamento ? null : aoExcluir,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Text('${compra.itens.length} itens'),
                const Spacer(),
                Text(
                  MonetarioUtils.formatarIntToMoeda(compra.valorTotal),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: porCategoria.entries
                    .map(
                      (entrada) => _GrupoItensHistorico(
                        titulo: entrada.key,
                        itens: entrada.value,
                        cor: cor,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrupoItensHistorico extends StatelessWidget {
  const _GrupoItensHistorico({
    required this.titulo,
    required this.itens,
    required this.cor,
  });

  final String titulo;
  final List<ItemHistorico> itens;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(Icons.category_outlined, color: cor),
      title: Text(titulo),
      subtitle: Text('${itens.length} ${itens.length == 1 ? 'item' : 'itens'}'),
      children: itens
          .map((item) => _ItemHistoricoTile(item: item, cor: cor))
          .toList(growable: false),
    );
  }
}

class _ItemHistoricoTile extends StatelessWidget {
  const _ItemHistoricoTile({required this.item, required this.cor});

  final ItemHistorico item;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final quantidade = item.unidadeMedida == 'kg'
        ? NumberFormat('0.000', 'pt_BR').format(item.quantidade / 1000)
        : item.quantidade.toString();
    final prioridade = switch (item.prioridade.name) {
      'alta' => 'A',
      'media' => 'M',
      'baixa' => 'B',
      _ => 'N',
    };
    return ListTile(
      dense: true,
      title: Text('${item.titulo} ($prioridade)'),
      subtitle: Text(
        '$quantidade ${item.unidadeMedida} x '
        '${MonetarioUtils.formatarIntToMoeda(item.preco)}'
        '${item.observacao?.trim().isNotEmpty == true ? '\n${item.observacao}' : ''}',
      ),
      trailing: Text(
        MonetarioUtils.formatarIntToMoeda(item.valorTotal),
        style: TextStyle(color: cor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
