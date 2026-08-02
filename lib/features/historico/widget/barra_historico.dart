import 'package:flutter/material.dart';

import '../model/filtro_historico.dart';

class BarraHistorico extends StatelessWidget {
  const BarraHistorico({
    super.key,
    required this.periodo,
    required this.ordenacao,
    required this.corDestaque,
    required this.aoPesquisar,
    required this.aoAlterarPeriodo,
    required this.aoAlterarOrdenacao,
  });

  final PeriodoHistorico periodo;
  final OrdenacaoHistorico ordenacao;
  final Color corDestaque;
  final ValueChanged<String> aoPesquisar;
  final ValueChanged<PeriodoHistorico> aoAlterarPeriodo;
  final ValueChanged<OrdenacaoHistorico> aoAlterarOrdenacao;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          children: [
            SearchBar(
              hintText: 'Pesquisar compras ou itens',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: aoPesquisar,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...PeriodoHistorico.values.map(
                    (valor) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(valor.rotulo),
                        selected: periodo == valor,
                        selectedColor: corDestaque.withValues(alpha: .16),
                        onSelected: (_) => aoAlterarPeriodo(valor),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                    child: VerticalDivider(width: 12),
                  ),
                  PopupMenuButton<OrdenacaoHistorico>(
                    tooltip: 'Ordenar histórico',
                    initialValue: ordenacao,
                    onSelected: aoAlterarOrdenacao,
                    itemBuilder: (_) => OrdenacaoHistorico.values
                        .map(
                          (valor) => PopupMenuItem(
                            value: valor,
                            child: Text(valor.rotulo),
                          ),
                        )
                        .toList(growable: false),
                    child: Chip(
                      avatar: const Icon(Icons.swap_vert, size: 18),
                      label: Text(ordenacao.rotulo),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
