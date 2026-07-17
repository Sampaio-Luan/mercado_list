import 'package:flutter/material.dart';

enum Cor {
  indigo,
  roxoEscuro,
  roxo,
  rosa,
  vermelho,
  laranjaEscuro,
  laranja,
  ambar,
  amarelo,
  lima,
  verdeClaro,
  verde,
  verdeAzulado,
  ciano,
  azulClaro,
  azul,
  azulCinzento,
  marrom;

  static String obterRotulo({required Cor cor}) => cor.name;

  static Cor obterPorRotulo({required String rotulo}) =>
      Cor.values.firstWhere((element) => element.name == rotulo);

  static Color obterCor({required Cor cor}) {
    switch (cor) {
      case Cor.vermelho:
        return Colors.red;
      case Cor.rosa:
        return Colors.pink;
      case Cor.roxo:
        return Colors.purple;
      case Cor.roxoEscuro:
        return Colors.deepPurple;
      case Cor.indigo:
        return Colors.indigo;
      case Cor.azul:
        return Colors.blue;
      case Cor.azulClaro:
        return Colors.lightBlue;
      case Cor.ciano:
        return Colors.cyan;
      case Cor.verdeAzulado:
        return Colors.teal;
      case Cor.verde:
        return Colors.green;
      case Cor.verdeClaro:
        return Colors.lightGreen;
      case Cor.lima:
        return Colors.lime;
      case Cor.amarelo:
        return Colors.yellow;
      case Cor.ambar:
        return Colors.amber;
      case Cor.laranja:
        return Colors.orange;
      case Cor.laranjaEscuro:
        return Colors.deepOrange;
      case Cor.marrom:
        return Colors.brown;
      case Cor.azulCinzento:
        return Colors.blueGrey;
    }
  }

  static List<Color> obterListaCores() {
    return Cor.values.map((cor) => obterCor(cor: cor)).toList();
  }

  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  static Cor obterPorColor({required Color color}) {
    for (var cor in Cor.values) {
      if (obterCor(cor: cor) == color) {
        return cor;
      }
    }
    throw Exception('Cor não encontrada para a cor fornecida.');
  }
}
