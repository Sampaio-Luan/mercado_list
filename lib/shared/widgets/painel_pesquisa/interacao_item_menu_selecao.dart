import 'package:flutter/widgets.dart';

class InteracaoItemMenuSelecao extends StatelessWidget {
  final Widget child;
  final bool selecaoAtiva;
  final VoidCallback aoAbrirMenu;
  final VoidCallback aoAlternarSelecao;

  const InteracaoItemMenuSelecao({
    super.key,
    required this.child,
    required this.selecaoAtiva,
    required this.aoAbrirMenu,
    required this.aoAlternarSelecao,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selecaoAtiva ? aoAlternarSelecao : aoAbrirMenu,
      onLongPress: selecaoAtiva ? aoAbrirMenu : aoAlternarSelecao,
      child: child,
    );
  }
}
