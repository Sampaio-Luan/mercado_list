import 'package:flutter/material.dart';

import 'utilitario_similaridade_texto.dart';

/// Widget que exibe um [texto] destacando em **negrito + cor primária**
/// (ou cores customizadas) os trechos que coincidem com [textoPesquisa].
///
/// A comparação é feita de forma insensível a maiúsculas/minúsculas e a
/// acentos, mas o texto original (com sua formatação visual original) é
/// sempre preservado na exibição.
///
/// Exemplo: ao pesquisar "sao" no texto "São Paulo", a substring "São"
/// será destacada corretamente mesmo com a diferença de acentuação.
class TextoComDestaquePesquisa extends StatelessWidget {
  const TextoComDestaquePesquisa({
    super.key,
    required this.texto,
    required this.textoPesquisa,
    this.estiloBase,
    this.estiloDestaque,
    this.maximoLinhas,
    this.overflow = TextOverflow.ellipsis,
  });

  /// Texto completo original a ser exibido (sem normalização).
  final String texto;

  /// Texto digitado pelo usuário na barra de pesquisa, usado para
  /// localizar os trechos que devem ser destacados.
  final String textoPesquisa;

  /// Estilo aplicado às partes do texto que **não** coincidem com a
  /// pesquisa. Caso nulo, usa o estilo padrão do tema (`bodyLarge`).
  final TextStyle? estiloBase;

  /// Estilo aplicado às partes do texto que **coincidem** com a pesquisa.
  /// Caso nulo, usa negrito + cor primária do tema atual.
  final TextStyle? estiloDestaque;

  /// Número máximo de linhas exibidas. Nulo significa sem limite.
  final int? maximoLinhas;

  /// Comportamento de corte de texto quando excede o espaço disponível.
  final TextOverflow overflow;

  /// Encontra todos os intervalos [início, fim) do [texto] (já considerando
  /// acentuação e caixa originais) que correspondem ao [termoPesquisa],
  /// comparando de forma normalizada (sem acento, minúsculo).
  List<_IntervaloDestaque> _localizarIntervalosCoincidentes() {
    final intervalos = <_IntervaloDestaque>[];

    final termoNormalizado =
        UtilitarioSimilaridadeTexto.normalizar(textoPesquisa);
    if (termoNormalizado.isEmpty) return intervalos;

    final textoNormalizado = UtilitarioSimilaridadeTexto.normalizar(texto);

    var indiceBusca = 0;
    while (true) {
      final indiceEncontrado =
          textoNormalizado.indexOf(termoNormalizado, indiceBusca);
      if (indiceEncontrado == -1) break;

      intervalos.add(
        _IntervaloDestaque(
          inicio: indiceEncontrado,
          fim: indiceEncontrado + termoNormalizado.length,
        ),
      );

      indiceBusca = indiceEncontrado + termoNormalizado.length;
    }

    return intervalos;
  }

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);

    final estiloBaseEfetivo =
        estiloBase ?? temaAtual.textTheme.bodyLarge ?? const TextStyle();

    final estiloDestaqueEfetivo = estiloDestaque ??
        estiloBaseEfetivo.copyWith(
          color: temaAtual.colorScheme.primary,
          fontWeight: FontWeight.bold,
        );

    final intervalosCoincidentes = _localizarIntervalosCoincidentes();

    // Caso não haja pesquisa ativa ou nenhuma coincidência, exibe o texto
    // puro sem custo adicional de processamento de spans.
    if (intervalosCoincidentes.isEmpty) {
      return Text(
        texto,
        style: estiloBaseEfetivo,
        maxLines: maximoLinhas,
        overflow: overflow,
      );
    }

    final listaSpans = <TextSpan>[];
    var posicaoAtual = 0;

    for (final intervalo in intervalosCoincidentes) {
      if (intervalo.inicio > posicaoAtual) {
        listaSpans.add(
          TextSpan(
            text: texto.substring(posicaoAtual, intervalo.inicio),
            style: estiloBaseEfetivo,
          ),
        );
      }

      listaSpans.add(
        TextSpan(
          text: texto.substring(intervalo.inicio, intervalo.fim),
          style: estiloDestaqueEfetivo,
        ),
      );

      posicaoAtual = intervalo.fim;
    }

    if (posicaoAtual < texto.length) {
      listaSpans.add(
        TextSpan(
          text: texto.substring(posicaoAtual),
          style: estiloBaseEfetivo,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: listaSpans),
      maxLines: maximoLinhas,
      overflow: overflow,
    );
  }
}

/// Representa um intervalo [inicio, fim) de caracteres dentro do texto
/// original que deve receber destaque visual.
class _IntervaloDestaque {
  const _IntervaloDestaque({required this.inicio, required this.fim});

  final int inicio;
  final int fim;
}
