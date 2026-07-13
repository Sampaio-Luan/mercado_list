import 'package:flutter/material.dart';

class Acao {
  final String titulo;
  final IconData? icone;
  final VoidCallback? aoSelecionar;
  final Color? cor;
  final bool destrutivo;
  final Widget? trailing;

  const Acao({
    required this.titulo,
    this.icone,
    this.aoSelecionar,
    this.cor,
    this.destrutivo = false,
    this.trailing,
  });
}
