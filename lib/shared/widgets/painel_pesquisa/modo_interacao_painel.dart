/// Define o comportamento de seleção de itens dentro do
/// `PainelPesquisa`.
enum ModoInteracaoPainel {
  /// O painel apenas apresenta os resultados. O widget de cada item é
  /// responsável por seus próprios gestos e ações.
  semSelecao,

  /// Permite que o usuário selecione **múltiplos itens** simultaneamente.
  /// Cada item exibe um indicador (checkbox) de seleção.
  multipla,

  /// Permite que o usuário selecione **apenas um item** por vez. Ao
  /// selecionar um novo item, a seleção anterior é automaticamente
  /// desfeita e o bottom sheet é fechado retornando o item escolhido.
  unica,
}

/// Define os pontos de ancoragem (snaps) de altura do bottom sheet,
/// representados como fração da altura total da tela (0.0 a 1.0).
abstract final class AlturasPainelPesquisa {
  /// Altura inicial ao abrir o bottom sheet (30% da tela).
  static const double inicial = 0.45;

  /// Primeiro ponto intermediário de arraste (60% da tela).
  static const double intermediario = 0.60;

  /// Segundo ponto intermediário de arraste, próximo do topo (90%).
  static const double expandido = 0.90;

  /// Altura máxima — tela cheia (100%).
  static const double telaCheia = 1.0;

  /// Lista ordenada de todos os pontos de ancoragem disponíveis, usada
  /// pelo `DraggableScrollableSheet` para definir os "snaps" de arraste.
  static const List<double> todos = [
    inicial,
    intermediario,
    expandido,
    telaCheia,
  ];
}
