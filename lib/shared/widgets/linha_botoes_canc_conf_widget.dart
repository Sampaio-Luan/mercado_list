import 'package:flutter/material.dart';

class LinhaBotoesConfirmacao extends StatelessWidget {
  final VoidCallback onCancelar;
  final VoidCallback onConfirmar;
  final Color? cor;
  final String textoConfirmar;
  final double? fontSize;

  const LinhaBotoesConfirmacao({
    super.key,
    required this.onCancelar,
    required this.onConfirmar,
    this.cor,
    this.textoConfirmar = 'Salvar',
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final Color corFinal = cor ?? Theme.of(context).colorScheme.primary;

    return Row(spacing: 10, children: [
      Expanded(
        child: OutlinedButton(
          onPressed: onCancelar,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: corFinal),
            foregroundColor: corFinal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ),
      ),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: corFinal,
          ),
          child: ElevatedButton(
            onPressed: onConfirmar,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: corFinal,
              foregroundColor:Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                textoConfirmar,
                style: TextStyle(fontSize: fontSize),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
