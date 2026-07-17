import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/constants/enums/cor.dart';


class SeletorDeCor extends StatelessWidget {
  final Cor corSelecionada;
  final Function(Cor cor) onCorSelecionada;
  const SeletorDeCor({
    super.key,
    required this.corSelecionada,
    required this.onCorSelecionada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(190),
        ),
      ),
      child: GridView.builder(
          itemCount: Cor.values.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            Color cor = Theme.of(context).brightness == Brightness.light
                ? Cor.obterCor(cor: Cor.values[index])
                : Cor.obterCor(cor: Cor.values[index]).withAlpha(200);
            return InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () => onCorSelecionada(Cor.values[index]),
              child: corSelecionada == Cor.values[index]
                  ? Container(
                      decoration: BoxDecoration(
                        color: cor.withAlpha(45),
                        border: Border.all(
                          width: 3,
                          color: cor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.sealCheckFill,
                        color: cor,
                        size: 30,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: cor,

                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
            );
          }),
    );
  }
}
