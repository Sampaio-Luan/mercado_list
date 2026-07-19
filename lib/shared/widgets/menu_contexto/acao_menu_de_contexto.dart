import 'dart:async';

import 'package:flutter/material.dart';

typedef ExecutarAcaoMenu = FutureOr<void> Function();

class AcaoMenuContexto {
  final String titulo;
  final IconData? icone;
  final ExecutarAcaoMenu? aoSelecionar;
  final Color? cor;
  final bool destrutivo;
  final Widget? trailing;

  const AcaoMenuContexto({
    required this.titulo,
    this.icone,
    this.aoSelecionar,
    this.cor,
    this.destrutivo = false,
    this.trailing,
  });

  Future<void> executar() async {
    final callback = aoSelecionar;
    if (callback != null) {
      await callback();
    }
  }
}
