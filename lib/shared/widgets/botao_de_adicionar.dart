import 'package:flutter/material.dart';

class BotaoDeAdicionar extends StatelessWidget {
  final Color? cor;
  final String titulo;
  final Function onPressed;
  final IconData? icon;
  const BotaoDeAdicionar({
    super.key,
    this.cor,
    required this.titulo,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:  Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => onPressed(),
        child: Container(
          decoration: BoxDecoration(
            color: cor ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Icon(
                icon ?? Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              Text(
                titulo,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
