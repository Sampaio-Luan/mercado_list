import 'package:flutter/material.dart';

import '../constants/enums/tipo_snackbar.dart';
import '../services/snackbar.service.dart';




extension SnackbarExtension on BuildContext {
  void mostrarSucesso(String mensagem) {
    SnackbarService.mostrar(
      context: this,
      mensagem: mensagem,
      tipo: TipoSnackbar.sucesso,
    );
  }

  void mostrarErro(String mensagem) {
    SnackbarService.mostrar(
      context: this,
      mensagem: mensagem,
      tipo: TipoSnackbar.erro,
    );
  }

  void mostrarAviso(String mensagem) {
    SnackbarService.mostrar(
      context: this,
      mensagem: mensagem,
      tipo: TipoSnackbar.aviso,
    );
  }

  void mostrarInfo(String mensagem) {
    SnackbarService.mostrar(
      context: this,
      mensagem: mensagem,
      tipo: TipoSnackbar.informacao,
    );
  }
}