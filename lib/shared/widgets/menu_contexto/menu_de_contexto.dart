import 'package:flutter/material.dart';

import 'acao_menu_de_contexto.dart';
import 'gatilho_menu_de_contexto.dart';
import 'sobreposicao_menu_de_contexto.dart';
import 'tema_menu_de_contexto.dart';

class MenuDeContexto extends StatelessWidget {
  final Widget child;
  final List<Acao> acoes;
  final Tema tema;
  final Gatilho gatilho;

  const MenuDeContexto({
    super.key,
    required this.child,
    required this.acoes,
    this.tema = const Tema(),
    this.gatilho = Gatilho.toque,
  });

  Future<void> abrir(BuildContext context) async {
    await showGeneralDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    switch (gatilho) {
      case Gatilho.toque:
        return GestureDetector(onTap: () => abrir(context), child: child);

      case Gatilho.toqueLongo:
        return GestureDetector(onLongPress: () => abrir(context), child: child);
    }
  }
}
