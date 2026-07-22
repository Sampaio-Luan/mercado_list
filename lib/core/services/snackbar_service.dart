import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../constants/enums/tipo_snackbar.dart';

class SnackbarService {
  SnackbarService._();

  static void mostrar({
    required BuildContext context,
    required String mensagem,
    required TipoSnackbar tipo,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(_construir(context, mensagem, tipo));
  }

  static void mostrarNoMensageiro({
    required ScaffoldMessengerState mensageiro,
    required BuildContext context,
    required String mensagem,
    required TipoSnackbar tipo,
  }) {
    mensageiro
      ..hideCurrentSnackBar()
      ..showSnackBar(_construir(context, mensagem, tipo));
  }

  static SnackBar _construir(
    BuildContext context,
    String mensagem,
    TipoSnackbar tipo,
  ) {
    final estilo = _EstiloSnackbar.obter(context, tipo);
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      backgroundColor: estilo.cor,
      content: Row(
        children: [
          Icon(estilo.icone, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(mensagem)),
        ],
      ),
    );
  }
}

class _EstiloSnackbar {
  final Color cor;
  final IconData icone;

  const _EstiloSnackbar({required this.cor, required this.icone});

  static _EstiloSnackbar obter(
    BuildContext context,
    TipoSnackbar tipo,
  ) {
    final cores = Theme.of(context).colorScheme;

    switch (tipo) {
      case TipoSnackbar.sucesso:
        return _EstiloSnackbar(
          cor: Colors.green.shade600,
          icone: PhosphorIcons.checkCircle,
        );
      case TipoSnackbar.erro:
        return _EstiloSnackbar(
          cor: cores.error,
          icone: PhosphorIcons.xCircle,
        );
      case TipoSnackbar.aviso:
        return _EstiloSnackbar(
          cor: Colors.orange.shade700,
          icone: PhosphorIcons.warning,
        );
      case TipoSnackbar.informacao:
        return _EstiloSnackbar(
          cor: cores.primary,
          icone: PhosphorIcons.info,
        );
    }
  }
}
