import 'package:flutter/material.dart';

enum Cor {
  azul,
  vermelho,
  verde,
  amarelo,
  roxo,
  laranja,
  cinza,
  preto;

  static String obterRotulo({required Cor cor}) => cor.name;

  static Cor obterPorRotulo({required String rotulo}) =>
      Cor.values.firstWhere((element) => element.name == rotulo);

  static Color obterCor({required Cor cor}){
    switch (cor) {
      case Cor.azul:
        return Colors.blueAccent;
      case Cor.vermelho:
        return Colors.red.shade900;
      case Cor.verde:
        return Colors.green;
      case Cor.amarelo:
        return Colors.amber;
      case Cor.roxo:
        return Colors.deepPurple;
      case Cor.laranja:
        return Colors.orange;
      case Cor.cinza:
        return Colors.grey;
      case Cor.preto:
        return Colors.black;
    }
  }

  static List<Color> obterListaCores() {
    return Cor.values.map((cor) => obterCor(cor: cor)).toList();
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
