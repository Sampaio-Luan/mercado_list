import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class RodapeAcoesItensRecorrentes extends StatelessWidget {
  final int quantidadeSelecionada;
  final VoidCallback aoAdicionar;
  final VoidCallback aoMover;
  final VoidCallback aoCriarCategoria;
  final VoidCallback aoExcluir;

  const RodapeAcoesItensRecorrentes({
    super.key,
    required this.quantidadeSelecionada,
    required this.aoAdicionar,
    required this.aoMover,
    required this.aoCriarCategoria,
    required this.aoExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: tema.colorScheme.surface,
          border: Border(
            top: BorderSide(color: tema.colorScheme.outlineVariant),
          ),
        ),
        child: quantidadeSelecionada == 0
            ? FilledButton.icon(
                onPressed: aoAdicionar,
                icon: const Icon(PhosphorIcons.plus),
                label: const Text('Adicionar item recorrente'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$quantidadeSelecionada selecionado${quantidadeSelecionada == 1 ? '' : 's'}',
                    style: tema.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AcaoSelecao(
                          icone: PhosphorIcons.folderSimple,
                          rotulo: 'Mover',
                          aoTocar: aoMover,
                        ),
                      ),
                      Expanded(
                        child: _AcaoSelecao(
                          icone: PhosphorIcons.folderSimplePlus,
                          rotulo: 'Nova categoria',
                          aoTocar: aoCriarCategoria,
                        ),
                      ),
                      Expanded(
                        child: _AcaoSelecao(
                          icone: PhosphorIcons.trash,
                          rotulo: 'Excluir',
                          cor: tema.colorScheme.error,
                          aoTocar: aoExcluir,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _AcaoSelecao extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final Color? cor;
  final VoidCallback aoTocar;

  const _AcaoSelecao({
    required this.icone,
    required this.rotulo,
    required this.aoTocar,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor),
            const SizedBox(height: 4),
            Text(
              rotulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cor),
            ),
          ],
        ),
      ),
    );
  }
}
