import 'package:flutter/material.dart';

import '../../../core/extensions/cor_contraste_extension.dart';

abstract final class EstiloSelecaoItens {
  static ButtonStyle segmentado(Color corSelecionada, ThemeData tema) {
    final corComContraste = corSelecionada.paraPrimeiroPlano(tema);
    return ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? corComContraste : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? corComContraste.corSobre
            : null,
      ),
    );
  }
}
