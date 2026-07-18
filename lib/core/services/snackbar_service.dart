import 'package:flutter/material.dart';

import '../constants/enums/tipo_snackbar.dart';

class SnackbarService {
  SnackbarService._();

  static void mostrar({
    required BuildContext context,
    required String mensagem,
    required TipoSnackbar tipo,
  }) {
    final estilo = _EstiloSnackbar.obter(context, tipo);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
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
          icone: Icons.check_circle,
        );
      case TipoSnackbar.erro:
        return _EstiloSnackbar(cor: cores.error, icone: Icons.error);
      case TipoSnackbar.aviso:
        return _EstiloSnackbar(
          cor: Colors.orange.shade700,
          icone: Icons.warning,
        );
      case TipoSnackbar.informacao:
        return _EstiloSnackbar(cor: cores.primary, icone: Icons.info);
    }
  }
}
