enum TipoMedida {
  kg,
  und;

  static String obterRotulo({required TipoMedida tipo}) {
    switch (tipo) {
      case TipoMedida.kg:
        return 'kg';
      case TipoMedida.und:
        return 'und';
    }
  }

  static TipoMedida obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'kg':
        return TipoMedida.kg;
      case 'und':
        return TipoMedida.und;
      default:
        throw TipoMedida.und;
    }
  }
}
