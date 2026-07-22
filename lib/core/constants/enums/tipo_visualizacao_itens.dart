enum TipoVisualizacaoItens {
  categorias,
  tabela;

  static String obterRotulo({required TipoVisualizacaoItens tipo}) {
    switch (tipo) {
      case TipoVisualizacaoItens.categorias:
        return TipoVisualizacaoItens.categorias.name;
      case TipoVisualizacaoItens.tabela:
        return TipoVisualizacaoItens.tabela.name;
    }
  }

  static TipoVisualizacaoItens obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'categorias':
      case 'lista':
        return TipoVisualizacaoItens.categorias;
      case 'tabela':
      case 'grade':
        return TipoVisualizacaoItens.tabela;
      default:
        return TipoVisualizacaoItens.categorias;
    }
  }
}
