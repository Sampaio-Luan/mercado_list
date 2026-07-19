import 'package:flutter/material.dart';

import 'estilo_painel_pesquisa.dart';
import 'modo_interacao_painel.dart';
import 'texto_destacado_pesquisa.dart';

/// Representa visualmente um único item dentro da lista de resultados do
/// `PainelPesquisa<T>`.
///
/// Exibe o texto principal (com destaque das partes coincidentes com a
/// pesquisa), um subtítulo opcional, e o indicador de seleção adequado ao
/// [modoSelecao] configurado (checkbox para múltipla, círculo para única).
class ItemPadraoPainelPesquisa<T> extends StatelessWidget {
  const ItemPadraoPainelPesquisa({
    super.key,
    required this.item,
    required this.textoExibicao,
    required this.textoPesquisa,
    required this.estaSelecionado,
    required this.modoSelecao,
    required this.aoTocarItem,
    required this.estilo,
    this.textoSubtitulo,
    this.iconeLideranca,
  });

  /// O item de dado genérico representado por esta linha.
  final T item;

  /// Texto principal de exibição do item (já obtido via
  /// `obterTextoPesquisa`).
  final String textoExibicao;

  /// Termo de pesquisa atual, usado para destacar trechos coincidentes.
  final String textoPesquisa;

  /// Indica se este item está atualmente selecionado.
  final bool estaSelecionado;

  /// Modo de seleção configurado (única ou múltipla), que determina qual
  /// indicador visual de seleção é exibido.
  final ModoInteracaoPainel modoSelecao;

  /// Callback chamado quando o usuário toca neste item.
  final VoidCallback aoTocarItem;

  /// Conjunto de propriedades visuais customizáveis.
  final EstiloPainelPesquisa estilo;

  /// Subtítulo opcional exibido abaixo do texto principal.
  final String? textoSubtitulo;

  /// Ícone (ou avatar) opcional exibido no início da linha, antes do texto.
  final Widget? iconeLideranca;

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);

    final corFundoSelecionado = estilo.corItemSelecionado ??
        temaAtual.colorScheme.primaryContainer.withValues(alpha: 0.4);

    return Material(
      color: estaSelecionado ? corFundoSelecionado : Colors.transparent,
      child: InkWell(
        onTap:
            modoSelecao == ModoInteracaoPainel.semSelecao ? null : aoTocarItem,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (iconeLideranca != null) ...[
                iconeLideranca!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextoDestacadoPesquisa(
                      texto: textoExibicao,
                      textoPesquisa: textoPesquisa,
                      estiloBase: estilo.estiloTextoItem ??
                          temaAtual.textTheme.bodyLarge,
                      estiloDestaque: estilo.estiloTextoItemDestacado,
                      maximoLinhas: 2,
                    ),
                    if (textoSubtitulo != null && textoSubtitulo!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          textoSubtitulo!,
                          style: estilo.estiloTextoSubtitulo ??
                              temaAtual.textTheme.bodySmall?.copyWith(
                                color: temaAtual.colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (modoSelecao != ModoInteracaoPainel.semSelecao) ...[
                const SizedBox(width: 8),
                _construirIndicadorSelecao(temaAtual),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o indicador visual de seleção adequado ao [modoSelecao]:
  /// um `Checkbox` para seleção múltipla, ou um ícone de círculo
  /// preenchido/vazio para seleção única.
  Widget _construirIndicadorSelecao(ThemeData temaAtual) {
    final corIndicador =
        estilo.corIconeSelecionado ?? temaAtual.colorScheme.primary;

    if (modoSelecao == ModoInteracaoPainel.multipla) {
      return Checkbox(
        value: estaSelecionado,
        activeColor: corIndicador,
        onChanged: (_) => aoTocarItem(),
      );
    }

    return Icon(
      estaSelecionado
          ? estilo.iconeItemSelecionadoUnico
          : estilo.iconeItemNaoSelecionadoUnico,
      color: estaSelecionado
          ? corIndicador
          : temaAtual.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
    );
  }
}
