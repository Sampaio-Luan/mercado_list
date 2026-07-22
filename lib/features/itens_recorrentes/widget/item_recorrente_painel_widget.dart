import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';
import '../model/item_recorrente_model.dart';

class ItemRecorrentePainelWidget extends StatelessWidget {
  final ItemRecorrente item;
  final String termoPesquisa;
  final Color corCategoria;
  final String tituloCategoria;
  final bool selecionado;

  const ItemRecorrentePainelWidget({
    super.key,
    required this.item,
    required this.termoPesquisa,
    required this.corCategoria,
    this.tituloCategoria = 'Sem categoria',
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      color: selecionado
          ? Color.alphaBlend(
              corCategoria.withAlpha(15),
              Theme.of(context).colorScheme.surface,
            )
          : Theme.of(context).colorScheme.surface,
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: corCategoria.withAlpha(45),
              foregroundColor: corCategoria,
              child: const Icon(PhosphorIcons.repeat),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextoDestacadoPesquisa(
                    texto: item.titulo,
                    textoPesquisa: termoPesquisa,
                    estiloBase: Theme.of(context).textTheme.titleMedium,
                    estiloDestaque: TextStyle(
                      color: corCategoria,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$tituloCategoria • ${item.tipoMedida.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selecionado
                  ? PhosphorIcons.check
                  : PhosphorIcons.dotsThreeVertical,
              color: selecionado ? corCategoria : null,
            ),
          ],
        ),
      ),
    );
  }
}
