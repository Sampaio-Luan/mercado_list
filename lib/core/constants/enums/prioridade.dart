import 'package:flutter/material.dart';

enum Prioridade {
  neutra,
  baixa,
  media,
  alta;

  static int obterRotulo({required Prioridade prioridade}) {
    switch (prioridade) {
      case Prioridade.baixa:
        return 1;
      case Prioridade.media:
        return 2;
      case Prioridade.alta:
        return 3;
      default:
        return 0;
    }
  }

  static Prioridade obterPorRotulo({required int rotulo}) {
    switch (rotulo) {
      case 1:
        return Prioridade.baixa;
      case 2:
        return Prioridade.media;
      case 3:
        return Prioridade.alta;
      default:
        return Prioridade.neutra;
    }
  }

  static Color obterCor({required Prioridade prioridade}) =>
      switch (prioridade) {
        Prioridade.neutra => Colors.blue,
        Prioridade.baixa => Colors.green,
        Prioridade.media => Colors.orange,
        Prioridade.alta => Colors.red,
      };
}
