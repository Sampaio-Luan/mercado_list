import 'package:flutter/material.dart';

class CarregamentoService {
  static bool _aberto = false;

  static Future<void> mostrar(
    BuildContext context,
  ) async {
    if (_aberto) return;

    _aberto = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  static void fechar(
    BuildContext context,
  ) {
    if (!_aberto) return;

    _aberto = false;

    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();
  }
}