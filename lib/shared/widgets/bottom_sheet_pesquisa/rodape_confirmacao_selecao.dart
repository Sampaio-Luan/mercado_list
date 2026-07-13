import 'package:flutter/material.dart';

/// Rodapé fixo exibido apenas no modo de seleção múltipla, contendo um
/// botão de confirmação que retorna os itens selecionados ao chamador do
/// bottom sheet.
///
/// Exibe a quantidade de itens selecionados no próprio rótulo do botão,
/// proporcionando feedback claro ao usuário.
class RodapeConfirmacaoSelecao extends StatelessWidget {
  const RodapeConfirmacaoSelecao({
    super.key,
    required this.quantidadeSelecionados,
    required this.aoConfirmar,
    this.textoBotaoConfirmar = 'Confirmar seleção',
    this.habilitarConfirmacaoSemSelecao = true,
  });

  /// Quantidade de itens atualmente selecionados.
  final int quantidadeSelecionados;

  /// Callback chamado ao tocar no botão de confirmação.
  final VoidCallback aoConfirmar;

  /// Texto base do botão de confirmação (a quantidade é anexada
  /// automaticamente quando maior que zero).
  final String textoBotaoConfirmar;

  /// Define se o botão de confirmação permanece habilitado mesmo quando
  /// nenhum item está selecionado (útil para permitir "confirmar lista
  /// vazia", limpando uma seleção anterior).
  final bool habilitarConfirmacaoSemSelecao;

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);
    final botaoEstaHabilitado =
        habilitarConfirmacaoSemSelecao || quantidadeSelecionados > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: temaAtual.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: temaAtual.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: FilledButton(
          onPressed: botaoEstaHabilitado ? aoConfirmar : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            quantidadeSelecionados > 0
                ? '$textoBotaoConfirmar ($quantidadeSelecionados)'
                : textoBotaoConfirmar,
          ),
        ),
      ),
    );
  }
}

/// Widget exibido quando a lista filtrada de resultados está vazia,
/// seja por ausência de itens ou por nenhuma correspondência encontrada
/// para o termo pesquisado.
class EstadoVazioListaPesquisa extends StatelessWidget {
  const EstadoVazioListaPesquisa({
    super.key,
    required this.mensagem,
    this.icone = Icons.search_off_rounded,
  });

  /// Mensagem explicativa exibida ao usuário.
  final String mensagem;

  /// Ícone ilustrativo exibido acima da mensagem.
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 48,
                color: temaAtual.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: temaAtual.textTheme.bodyMedium?.copyWith(
                  color: temaAtual.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
