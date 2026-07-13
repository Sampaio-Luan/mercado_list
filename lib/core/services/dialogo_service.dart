import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/enums/tipo_dialogo.dart';



class DialogoService {
  DialogoService._();

  static Future<ResultadoDialogo?> mostrar({
    required BuildContext context,
    required TipoDialogo tipo,
    required String titulo,
    required String mensagem,
    String textoConfirmar = 'OK',
    String textoCancelar = 'Cancelar',
    bool exibirCancelar = false,
  }) {
    final estilo = _EstiloDialogo.obter(
      context,
      tipo,
    );

    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: !exibirCancelar,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(
        milliseconds: 250,
      ),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curva = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4,
            sigmaY: 4,
          ),
          child: FadeTransition(
            opacity: curva,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: .90,
                end: 1,
              ).animate(curva),
              child: DialogoBase(
                titulo: titulo,
                mensagem: mensagem,
                icone: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: estilo.cor.withValues(
                      alpha: .12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    estilo.icone,
                    size: 36,
                    color: estilo.cor,
                  ),
                ),
                acoes: [
                  if (exibirCancelar)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            ResultadoDialogo.cancelar,
                          );
                        },
                        child: Text(textoCancelar),
                      ),
                    ),

                  if (exibirCancelar)
                    const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: estilo.cor,
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          ResultadoDialogo.confirmar,
                        );
                      },
                      child: Text(textoConfirmar),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EstiloDialogo {
  final Color cor;
  final IconData icone;

  const _EstiloDialogo({
    required this.cor,
    required this.icone,
  });

  static _EstiloDialogo obter(
    BuildContext context,
    TipoDialogo tipo,
  ) {
    final cores = Theme.of(context).colorScheme;

    switch (tipo) {
      case TipoDialogo.sucesso:
        return _EstiloDialogo(
          cor: Colors.green.shade600,
          icone: Icons.check_circle_rounded,
        );

      case TipoDialogo.erro:
        return _EstiloDialogo(
          cor: cores.error,
          icone: Icons.error_rounded,
        );

      case TipoDialogo.aviso:
        return _EstiloDialogo(
          cor: Colors.orange.shade700,
          icone: Icons.warning_amber_rounded,
        );

      case TipoDialogo.informacao:
        return _EstiloDialogo(
          cor: cores.primary,
          icone: Icons.info_rounded,
        );
    }
  }
}