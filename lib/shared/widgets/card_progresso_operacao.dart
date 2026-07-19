import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum EstadoProgressoOperacao { processando, sucesso, erro }

class CardProgressoOperacao extends StatelessWidget {
  final String titulo;
  final String descricao;
  final int etapaAtual;
  final int totalEtapas;
  final EstadoProgressoOperacao estado;
  final VoidCallback? onFechar;

  const CardProgressoOperacao({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.etapaAtual,
    required this.totalEtapas,
    required this.estado,
    this.onFechar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final progresso = totalEtapas > 0
        ? (etapaAtual / totalEtapas).clamp(0.0, 1.0).toDouble()
        : null;

    return PopScope(
      canPop: estado == EstadoProgressoOperacao.erro,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IndicadorEstado(estado: estado),
                const SizedBox(height: 20),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    descricao,
                    key: ValueKey(descricao),
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value:
                      estado == EstadoProgressoOperacao.sucesso ? 1 : progresso,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 10),
                Text(
                  totalEtapas > 0
                      ? '$etapaAtual/$totalEtapas'
                      : 'Preparando...',
                  textAlign: TextAlign.end,
                  style: tema.textTheme.labelMedium?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (estado == EstadoProgressoOperacao.erro) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onFechar,
                    child: const Text('Fechar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicadorEstado extends StatelessWidget {
  final EstadoProgressoOperacao estado;

  const _IndicadorEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return SizedBox(
      height: 64,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: switch (estado) {
          EstadoProgressoOperacao.processando => SizedBox(
              key: const ValueKey('processando'),
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: cores.primary,
              ),
            ),
          EstadoProgressoOperacao.sucesso => Icon(
              PhosphorIcons.checkCircle,
              key: const ValueKey('sucesso'),
              size: 64,
              color: Colors.green.shade600,
            ),
          EstadoProgressoOperacao.erro => Icon(
              PhosphorIcons.xCircle,
              key: const ValueKey('erro'),
              size: 64,
              color: cores.error,
            ),
        },
      ),
    );
  }
}
