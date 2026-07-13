/// Utilitário responsável por cálculos de similaridade textual e
/// normalização de strings (remoção de acentos, caixa, etc.).
///
/// Implementa dois algoritmos complementares:
/// - **Distância de Levenshtein**: usada no cálculo principal de
///   relevância (fallback fuzzy), pois é previsível e intuitiva para
///   erros de digitação — conta exatamente quantas inserções, remoções
///   ou substituições separam duas palavras.
/// - **Jaro-Winkler**: disponível como utilitário público para quem
///   quiser usá-lo diretamente, mas não é mais usado no cálculo de
///   relevância padrão porque tende a gerar pontuações artificialmente
///   altas para termos curtos sem relação real com a palavra comparada.
library;

/// Classe utilitária estática (não instanciável) com funções puras de
/// comparação e normalização de texto.
abstract final class UtilitarioSimilaridadeTexto {
  /// Mapa de caracteres acentuados para seus equivalentes sem acento.
  /// Usado para tornar a busca insensível a acentuação.
  static const Map<String, String> _mapaCaracteresAcentuados = {
    'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
    'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
    'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
    'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
    'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ô': 'O', 'Ö': 'O',
    'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
    'Ç': 'C', 'Ñ': 'N',
  };

  /// Remove acentos de uma string, preservando a caixa (maiúscula/minúscula)
  /// dos caracteres originais.
  static String removerAcentos(String texto) {
    final buffer = StringBuffer();
    for (final caractere in texto.split('')) {
      buffer.write(_mapaCaracteresAcentuados[caractere] ?? caractere);
    }
    return buffer.toString();
  }

  /// Normaliza um texto para fins de comparação: remove acentos e
  /// converte para minúsculas.
  static String normalizar(String texto) {
    return removerAcentos(texto).toLowerCase().trim();
  }

  /// Calcula a **distância de Levenshtein** entre duas strings: o número
  /// mínimo de inserções, remoções ou substituições de caractere
  /// necessárias para transformar [textoA] em [textoB].
  ///
  /// Implementação iterativa com complexidade O(n*m) em tempo e O(min(n,m))
  /// em espaço (mantém apenas a linha anterior da matriz de programação
  /// dinâmica, em vez da matriz completa).
  static int calcularDistanciaLevenshtein(String textoA, String textoB) {
    if (textoA == textoB) return 0;

    final tamanhoA = textoA.length;
    final tamanhoB = textoB.length;

    if (tamanhoA == 0) return tamanhoB;
    if (tamanhoB == 0) return tamanhoA;

    var linhaAnterior = List<int>.generate(tamanhoB + 1, (indice) => indice);
    var linhaAtual = List<int>.filled(tamanhoB + 1, 0);

    for (var indiceA = 1; indiceA <= tamanhoA; indiceA++) {
      linhaAtual[0] = indiceA;

      for (var indiceB = 1; indiceB <= tamanhoB; indiceB++) {
        final custoSubstituicao =
            textoA[indiceA - 1] == textoB[indiceB - 1] ? 0 : 1;

        final remocao = linhaAnterior[indiceB] + 1;
        final insercao = linhaAtual[indiceB - 1] + 1;
        final substituicao = linhaAnterior[indiceB - 1] + custoSubstituicao;

        linhaAtual[indiceB] = [remocao, insercao, substituicao]
            .reduce((valorAtual, valor) => valor < valorAtual ? valor : valorAtual);
      }

      final linhaTemporaria = linhaAnterior;
      linhaAnterior = linhaAtual;
      linhaAtual = linhaTemporaria;
    }

    return linhaAnterior[tamanhoB];
  }

  /// Calcula a similaridade de Jaro entre duas strings.
  /// Retorna um valor entre 0.0 (totalmente diferente) e 1.0 (idêntico).
  static double _calcularSimilaridadeJaro(String textoA, String textoB) {
    if (textoA == textoB) return 1.0;

    final tamanhoA = textoA.length;
    final tamanhoB = textoB.length;

    if (tamanhoA == 0 || tamanhoB == 0) return 0.0;

    final distanciaMaximaCorrespondencia =
        (tamanhoA > tamanhoB ? tamanhoA : tamanhoB) ~/ 2;

    final correspondenciasA = List<bool>.filled(tamanhoA, false);
    final correspondenciasB = List<bool>.filled(tamanhoB, false);

    var quantidadeCorrespondencias = 0;

    // Etapa 1: encontrar correspondências dentro da janela permitida.
    for (var indiceA = 0; indiceA < tamanhoA; indiceA++) {
      final limiteInferior =
          (indiceA - distanciaMaximaCorrespondencia).clamp(0, tamanhoB);
      final limiteSuperior =
          (indiceA + distanciaMaximaCorrespondencia + 1).clamp(0, tamanhoB);

      for (var indiceB = limiteInferior; indiceB < limiteSuperior; indiceB++) {
        if (correspondenciasB[indiceB]) continue;
        if (textoA[indiceA] != textoB[indiceB]) continue;

        correspondenciasA[indiceA] = true;
        correspondenciasB[indiceB] = true;
        quantidadeCorrespondencias++;
        break;
      }
    }

    if (quantidadeCorrespondencias == 0) return 0.0;

    // Etapa 2: contar transposições.
    var quantidadeTransposicoes = 0;
    var indiceComparacaoB = 0;

    for (var indiceA = 0; indiceA < tamanhoA; indiceA++) {
      if (!correspondenciasA[indiceA]) continue;

      while (!correspondenciasB[indiceComparacaoB]) {
        indiceComparacaoB++;
      }

      if (textoA[indiceA] != textoB[indiceComparacaoB]) {
        quantidadeTransposicoes++;
      }
      indiceComparacaoB++;
    }

    quantidadeTransposicoes ~/= 2;

    final similaridade = (quantidadeCorrespondencias / tamanhoA +
            quantidadeCorrespondencias / tamanhoB +
            (quantidadeCorrespondencias - quantidadeTransposicoes) /
                quantidadeCorrespondencias) /
        3.0;

    return similaridade;
  }

  /// Calcula a similaridade de **Jaro-Winkler** entre dois textos.
  ///
  /// É uma variação do algoritmo de Jaro que dá peso extra quando os
  /// textos compartilham um prefixo comum, o que é ideal para buscas
  /// onde o usuário digita o início da palavra.
  ///
  /// Disponível como utilitário público, mas **não** é usado pelo
  /// cálculo padrão de [calcularPontuacaoRelevancia] — veja a
  /// documentação da classe para o motivo.
  ///
  /// [pesoPrefixo] define o quanto o prefixo comum influencia o resultado
  /// final (padrão de mercado: 0.1). [tamanhoMaximoPrefixo] limita quantos
  /// caracteres do prefixo são considerados (padrão: 4).
  static double calcularSimilaridadeJaroWinkler(
    String textoA,
    String textoB, {
    double pesoPrefixo = 0.1,
    int tamanhoMaximoPrefixo = 4,
  }) {
    final similaridadeJaro = _calcularSimilaridadeJaro(textoA, textoB);

    var tamanhoPrefixoComum = 0;
    final tamanhoLimite = [
      textoA.length,
      textoB.length,
      tamanhoMaximoPrefixo,
    ].reduce((valorAtual, valorComparado) =>
        valorAtual < valorComparado ? valorAtual : valorComparado);

    for (var indice = 0; indice < tamanhoLimite; indice++) {
      if (textoA[indice] == textoB[indice]) {
        tamanhoPrefixoComum++;
      } else {
        break;
      }
    }

    return similaridadeJaro +
        (tamanhoPrefixoComum * pesoPrefixo * (1 - similaridadeJaro));
  }

  /// Calcula a pontuação de relevância de uma [textoItem] em relação ao
  /// [textoPesquisa] digitado pelo usuário, combinando, em ordem de
  /// prioridade:
  /// 1. Igualdade exata → 1.0.
  /// 2. Prefixo do item igual à pesquisa → 0.97.
  /// 3. Pesquisa contida em qualquer posição do item → 0.92.
  /// 4. Erro de digitação (distância de Levenshtein) em alguma palavra
  ///    do item → entre 0.0 (não relevante) e ~0.8.
  ///
  /// Retorna um valor entre 0.0 e 1.0, onde 0.0 significa "sem relação
  /// alguma" e deve ser filtrado pelo chamador. Ambos os textos são
  /// normalizados internamente (sem acento, minúsculo) antes da
  /// comparação.
  ///
  /// A etapa fuzzy (4) compara a pesquisa contra cada **palavra
  /// individual** do item (não contra o texto inteiro) usando a
  /// distância de Levenshtein, com uma tolerância de edições
  /// proporcional ao tamanho do termo pesquisado. Isso garante que
  /// apenas erros de digitação plausíveis (poucas letras trocadas,
  /// faltando ou sobrando) sejam aceitos, evitando que palavras curtas
  /// e genuinamente diferentes apareçam como falsos positivos.
  static double calcularPontuacaoRelevancia({
    required String textoItem,
    required String textoPesquisa,
  }) {
    final itemNormalizado = normalizar(textoItem);
    final pesquisaNormalizada = normalizar(textoPesquisa);

    if (pesquisaNormalizada.isEmpty) return 1.0;
    if (itemNormalizado == pesquisaNormalizada) return 1.0;

    // Correspondência de prefixo tem prioridade altíssima.
    if (itemNormalizado.startsWith(pesquisaNormalizada)) {
      return 0.97;
    }

    // Substring em qualquer posição também é fortemente relevante
    // (cobre o caso de pesquisar parte de uma palavra no meio do texto,
    // como pesquisar "pau" e encontrar "São Paulo").
    if (itemNormalizado.contains(pesquisaNormalizada)) {
      return 0.92;
    }

    // Caso não haja correspondência direta, recorre à tolerância a erros
    // de digitação (fuzzy), comparando a pesquisa contra cada palavra do
    // item separadamente.
    final palavrasDoItem = itemNormalizado.split(RegExp(r'\s+'));
    final tamanhoPesquisa = pesquisaNormalizada.length;

    // Distância máxima de edições tolerada, proporcional ao tamanho do
    // termo pesquisado: termos muito curtos toleram só 1 erro; termos
    // médios toleram 2; termos longos toleram 3.
    final distanciaMaximaTolerada =
        tamanhoPesquisa <= 4 ? 1 : (tamanhoPesquisa <= 8 ? 2 : 3);

    var melhorPontuacaoFuzzy = 0.0;

    for (final palavra in palavrasDoItem) {
      if (palavra.isEmpty) continue;

      final distancia =
          calcularDistanciaLevenshtein(palavra, pesquisaNormalizada);

      if (distancia > distanciaMaximaTolerada) continue;

      final tamanhoMaximo =
          palavra.length > tamanhoPesquisa ? palavra.length : tamanhoPesquisa;
      final pontuacaoFuzzy = 1.0 - (distancia / tamanhoMaximo);

      if (pontuacaoFuzzy > melhorPontuacaoFuzzy) {
        melhorPontuacaoFuzzy = pontuacaoFuzzy;
      }
    }

    if (melhorPontuacaoFuzzy <= 0.0) return 0.0;

    // Penaliza o resultado fuzzy para que fique sempre abaixo das
    // correspondências diretas (prefixo/substring).
    return melhorPontuacaoFuzzy * 0.8;
  }
}
