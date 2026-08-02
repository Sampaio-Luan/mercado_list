import 'package:flutter/material.dart';

import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/utils/data_utils.dart';
import '../../../core/utils/monetario_utils.dart';
import '../model/historico_com_itens_model.dart';

class HistoricoCard extends StatelessWidget {
  const HistoricoCard({
    super.key,
    required this.compra,
    required this.aoAbrir,
    required this.aoCompartilhar,
  });

  final HistoricoComItens compra;
  final VoidCallback aoAbrir;
  final VoidCallback aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = compra.historico.cor.paraPrimeiroPlano(tema);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 62,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compra.historico.titulo,
                      style: tema.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DataUtils.formatarData(compra.historico.dataCompra),
                      style: tema.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${compra.itens.length} ${compra.itens.length == 1 ? 'item' : 'itens'}  •  '
                      '${MonetarioUtils.formatarIntToMoeda(compra.valorTotal)}',
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Compartilhar compra',
                onPressed: compra.itens.isEmpty ? null : aoCompartilhar,
                color: cor,
                icon: const Icon(Icons.ios_share_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
