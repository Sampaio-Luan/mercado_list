import '../model/categoria_model.dart';

extension ConsultaCategorias on Iterable<Categoria> {
  Categoria? localizarPorId(int? idCategoria) {
    if (idCategoria == null) return null;

    for (final categoria in this) {
      if (categoria.id == idCategoria) return categoria;
    }
    return null;
  }

  String tituloPorId(
    int? idCategoria, {
    String tituloAusente = 'Todas as categorias',
  }) {
    return localizarPorId(idCategoria)?.titulo ?? tituloAusente;
  }
}
