import 'package:flutter/material.dart';

import 'estilo_painel_pesquisa.dart';

/// Cabeçalho fixo do bottom sheet, contendo:
/// - Alça de arraste (indicativo visual).
/// - Título configurável.
/// - Botão para alternar entre tela cheia e tamanho anterior.
/// - Botão de fechar (X).
class CabecalhoPainelPesquisa extends StatelessWidget {
  const CabecalhoPainelPesquisa({
    super.key,
    required this.titulo,
    required this.estaEmTelaCheia,
    required this.aoAlternarTelaCheia,
    required this.aoFechar,
    required this.estilo,
    this.acoes = const [],
  });

  /// Texto do título exibido no cabeçalho.
  final String titulo;

  /// Indica se o bottom sheet está atualmente em modo tela cheia,
  /// usado para decidir qual ícone exibir (expandir ou recolher).
  final bool estaEmTelaCheia;

  /// Callback chamado ao tocar no botão de alternância de tela cheia.
  final VoidCallback aoAlternarTelaCheia;

  /// Callback chamado ao tocar no botão de fechar.
  final VoidCallback aoFechar;

  /// Conjunto de propriedades visuais customizáveis.
  final EstiloPainelPesquisa estilo;

  final List<Widget> acoes;

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alça de arraste — indicativo visual de que o painel é arrastável.
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 6),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: estilo.corAlcaArraste ??
                  temaAtual.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: estilo.estiloTitulo ??
                      temaAtual.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...acoes,
              IconButton(
                icon: Icon(
                  estaEmTelaCheia ? estilo.iconeRecolher : estilo.iconeExpandir,
                  color: estilo.corIconeTelaCheia ??
                      temaAtual.colorScheme.onSurfaceVariant,
                ),
                tooltip:
                    estaEmTelaCheia ? 'Recolher' : 'Expandir para tela cheia',
                onPressed: aoAlternarTelaCheia,
              ),
              IconButton(
                icon: Icon(
                  estilo.iconeFechar,
                  color: estilo.corIconeFechar ??
                      temaAtual.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Fechar',
                onPressed: aoFechar,
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 0.3,
        ),
      ],
    );
  }
}
