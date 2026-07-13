enum TemaApp {
  sistema,
  claro,
  escuro;

  static String obterRotulo({required TemaApp tema}) {
    switch (tema) {
      case TemaApp.sistema:
        return 'sistema';
      case TemaApp.claro:
        return 'claro';
      case TemaApp.escuro:
        return 'escuro';
    }
  }

  static TemaApp obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'sistema':
        return TemaApp.sistema;
      case 'claro':
        return TemaApp.claro;
      case 'escuro':
        return TemaApp.escuro;
      default:
        throw TemaApp.sistema;
    }
  }
}
