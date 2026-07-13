import 'package:flutter/material.dart';

class DialogoBase extends StatelessWidget {
  final Widget icone;
  final String titulo;
  final String mensagem;
  final List<Widget> acoes;

  const DialogoBase({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    required this.acoes,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return AlertDialog(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: tema.colorScheme.surface,
      contentPadding: const EdgeInsets.all(15),
      icon: icone,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 15,
        children: [
          Text(
            titulo,
            style: tema.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.onSurface.withAlpha(200),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10.0,
            ),
            child: Text(
              mensagem,
              textAlign: TextAlign.justify,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
                //height: 1.5,
              ),
            ),
          ),

          Row(children: acoes),
        ],
      ),
    );
  }
}
