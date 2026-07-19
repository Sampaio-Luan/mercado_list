import 'package:flutter/material.dart';

import 'estilo_painel_pesquisa.dart';

/// Barra de pesquisa fixa exibida no cabeçalho do bottom sheet.
///
/// Encapsula um [TextField] estilizado de acordo com o Material 3,
/// incluindo ícone de pesquisa, botão de limpar (exibido apenas quando há
/// texto digitado) e suporte total a customização visual via
/// [EstiloPainelPesquisa].
class CampoPainelPesquisa extends StatelessWidget {
  const CampoPainelPesquisa({
    super.key,
    required this.controladorTexto,
    required this.aoAlterarTexto,
    required this.aoLimparTexto,
    required this.estilo,
    this.textoPlaceholder = 'Pesquisar...',
    this.focoCampo,
  });

  /// Controlador de texto do campo de pesquisa.
  final TextEditingController controladorTexto;

  /// Callback chamado a cada alteração do texto digitado.
  final ValueChanged<String> aoAlterarTexto;

  /// Callback chamado quando o usuário limpa o campo de pesquisa.
  final VoidCallback aoLimparTexto;

  /// Conjunto de propriedades visuais customizáveis.
  final EstiloPainelPesquisa estilo;

  /// Texto de dica exibido quando o campo está vazio.
  final String textoPlaceholder;

  /// Nó de foco opcional, usado para controlar o foco do campo
  /// externamente (por exemplo, para abrir o teclado automaticamente).
  final FocusNode? focoCampo;

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controladorTexto,
        focusNode: focoCampo,
        onChanged: aoAlterarTexto,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: textoPlaceholder,
          prefixIcon: Icon(
            estilo.iconePesquisa,
            color: temaAtual.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controladorTexto,
            builder: (contextoConstrucao, valorTexto, _) {
              if (valorTexto.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  estilo.iconeLimparPesquisa,
                  color: temaAtual.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Limpar pesquisa',
                onPressed: aoLimparTexto,
              );
            },
          ),
          filled: true,
          fillColor: estilo.corFundoCampoPainelPesquisa ??
              temaAtual.colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(estilo.raioBordaCampoPainelPesquisa),
            borderSide: BorderSide(
              color: estilo.corBordaCampoPainelPesquisa ?? Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(estilo.raioBordaCampoPainelPesquisa),
            borderSide: BorderSide(
              color: estilo.corBordaCampoPainelPesquisa ?? Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(estilo.raioBordaCampoPainelPesquisa),
            borderSide: BorderSide(
              color: temaAtual.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
