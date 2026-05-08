enum TipoVisualizacaoItens {
  lista,
  grade;

  static String obterRotulo({required TipoVisualizacaoItens tipo}) {
    switch (tipo) {
      case TipoVisualizacaoItens.lista:
        return TipoVisualizacaoItens.lista.name;
      case TipoVisualizacaoItens.grade:
        return TipoVisualizacaoItens.grade.name;
    }
  }

  static TipoVisualizacaoItens obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'lista':
        return TipoVisualizacaoItens.lista;
      case 'grade':
        return TipoVisualizacaoItens.grade;
      default:
        return TipoVisualizacaoItens.grade;
    }
  }
}
