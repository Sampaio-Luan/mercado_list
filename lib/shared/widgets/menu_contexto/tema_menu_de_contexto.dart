import 'package:flutter/material.dart';

class TemaMenuContexto {
  final bool glassmorphism;

  final double blurFundo;
  final double blurCard;

  final double largura;

  final BorderRadius borderRadius;

  final Duration duracaoAnimacao;

  final Color? corFundo;
  final Color? corBorda;

  const TemaMenuContexto({
    this.glassmorphism = true,
    this.blurFundo = 10,
    this.blurCard = 20,
    this.largura = 280,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.duracaoAnimacao = const Duration(milliseconds: 250),
    this.corFundo,
    this.corBorda,
  });
}
