import 'package:flutter/material.dart';

import 'acao_menu_de_contexto.dart';
import 'gatilho_menu_de_contexto.dart';
import 'sobreposicao_menu_de_contexto.dart';
import 'tema_menu_de_contexto.dart';

class MenuDeContexto extends StatelessWidget {
  final Widget child;
  final List<AcaoMenuContexto> acoes;
  final TemaMenuContexto tema;
  final GatilhoMenuContexto gatilho;

  const MenuDeContexto({
    super.key,
    required this.child,
    required this.acoes,
    this.tema = const TemaMenuContexto(),
    this.gatilho = GatilhoMenuContexto.toque,
  });

  Future<void> abrir(BuildContext context) async {
    final acao = await showGeneralDialog<AcaoMenuContexto>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: tema.duracaoAnimacao,
      pageBuilder: (_, _, _) {
        return Sobreposicao(widgetCentral: child, acoes: acoes, tema: tema);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .98, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
    if (acao != null) {
      await Future<void>.delayed(
        tema.duracaoAnimacao + const Duration(milliseconds: 50),
      );
      if (context.mounted) {
        await acao.executar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (gatilho) {
      case GatilhoMenuContexto.toque:
        return GestureDetector(onTap: () => abrir(context), child: child);

      case GatilhoMenuContexto.toqueLongo:
        return GestureDetector(onLongPress: () => abrir(context), child: child);
    }
  }
}
