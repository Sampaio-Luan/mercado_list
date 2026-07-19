import 'package:flutter/widgets.dart';

import 'controlador_painel_pesquisa.dart';

class ContextoItemPesquisa<T> {
  final T item;
  final String termoPesquisa;
  final bool selecionado;
  final ControladorPainelPesquisa<T> controlador;

  const ContextoItemPesquisa({
    required this.item,
    required this.termoPesquisa,
    required this.selecionado,
    required this.controlador,
  });

  void alternarSelecao() => controlador.alternarSelecaoItem(item);

  void atualizar(T itemAtualizado) {
    controlador.atualizarItem(item, itemAtualizado);
  }

  void remover() => controlador.removerItem(item);
}

typedef ConstrutorItemPesquisa<T> = Widget Function(
  BuildContext context,
  ContextoItemPesquisa<T> resultado,
);

typedef ConstrutorAcoesPainel<T> = List<Widget> Function(
  BuildContext context,
  ControladorPainelPesquisa<T> controlador,
);

typedef ConstrutorRodapePainel<T> = Widget Function(
  BuildContext context,
  ControladorPainelPesquisa<T> controlador,
);
