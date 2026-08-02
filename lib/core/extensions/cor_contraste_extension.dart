import 'package:flutter/material.dart';

extension CorContrasteExtension on Color {
  Color paraPrimeiroPlano(
    ThemeData tema, {
    Color? superficie,
    double contrasteMinimo = 4.5,
  }) {
    final fundo = superficie ?? tema.colorScheme.surface;
    return contrasteCom(fundo) >= contrasteMinimo
        ? this
        : tema.colorScheme.onSurface;
  }

  Color get corSobre {
    final contrasteBranco = contrasteCom(Colors.white);
    final contrastePreto = contrasteCom(Colors.black);
    return contrasteBranco >= contrastePreto ? Colors.white : Colors.black;
  }

  double contrasteCom(Color outra) {
    final luminanciaAtual = computeLuminance();
    final luminanciaOutra = outra.computeLuminance();
    final maisClara =
        luminanciaAtual > luminanciaOutra ? luminanciaAtual : luminanciaOutra;
    final maisEscura =
        luminanciaAtual > luminanciaOutra ? luminanciaOutra : luminanciaAtual;
    return (maisClara + .05) / (maisEscura + .05);
  }
}
