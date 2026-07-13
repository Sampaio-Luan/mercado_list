enum Ordem {
  ascendente,
  descendente;

  static String obterRotulo({required Ordem tipo}) {
    switch (tipo) {
      case Ordem.ascendente:
        return 'Ascendente';
      case Ordem.descendente:
        return 'Descendente';
    }
  }

  static Ordem obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'Ascendente':
        return Ordem.ascendente;
      case 'Descendente':
        return Ordem.descendente;
      default:
        return Ordem.ascendente;
    }
  }
}
