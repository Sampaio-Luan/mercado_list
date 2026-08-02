import 'package:flutter/material.dart';

abstract final class EstiloSelecaoItens {
  static ButtonStyle segmentado(Color corSelecionada) {
    return ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (estados) =>
            estados.contains(WidgetState.selected) ? corSelecionada : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? corSobre(corSelecionada)
            : null,
      ),
    );
  }

  static Color corSobre(Color fundo) {
    return ThemeData.estimateBrightnessForColor(fundo) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
