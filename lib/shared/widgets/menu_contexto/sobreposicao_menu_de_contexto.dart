import 'dart:ui';

import 'package:flutter/material.dart';

import 'acao_menu_de_contexto.dart';
import 'tema_menu_de_contexto.dart';

class Sobreposicao extends StatelessWidget {
  final Widget widgetCentral;
  final List<AcaoMenuContexto> acoes;
  final TemaMenuContexto tema;

  const Sobreposicao({
    super.key,
    required this.widgetCentral,
    required this.acoes,
    required this.tema,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: tema.blurFundo,
                  sigmaY: tema.blurFundo,
                ),
                child: Container(
                  color: Theme.of(context).colorScheme.surface.withAlpha(10),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                widgetCentral,
                _CardMenu(acoes: acoes, tema: tema, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMenu extends StatelessWidget {
  final List<AcaoMenuContexto> acoes;
  final TemaMenuContexto tema;
  final ColorScheme colors;

  const _CardMenu({
    required this.acoes,
    required this.tema,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    int i = 0;
    Widget card = Container(
      width: tema.largura,
      decoration: BoxDecoration(
        borderRadius: tema.borderRadius,
        color: tema.corFundo ??
            (tema.glassmorphism
                ? Colors.white.withValues(alpha: .10)
                : colors.surface),
        border: Border.all(
          color: tema.corBorda ?? Colors.white.withValues(alpha: .15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: acoes.map((acao) {
          final cor =
              acao.cor ?? (acao.destrutivo ? colors.error : colors.onSurface);
          i++;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.pop(context, acao);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                spacing: 15,
                children: [
                  Row(
                    children: [
                      if (acao.icone != null) Icon(acao.icone, color: cor),
                      if (acao.icone != null) const SizedBox(width: 12),
                      Expanded(
                        child: Text(acao.titulo, style: TextStyle(color: cor)),
                      ),
                      if (acao.trailing != null) acao.trailing!,
                    ],
                  ),
                  if (i != acoes.length)
                    Divider(
                      height: 0.3,
                      thickness: 0.5,
                      color:
                          Theme.of(context).colorScheme.onSurface.withAlpha(10),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (!tema.glassmorphism) {
      return card;
    }

    return ClipRRect(
      borderRadius: tema.borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: tema.blurCard, sigmaY: tema.blurCard),
        child: card,
      ),
    );
  }
}
