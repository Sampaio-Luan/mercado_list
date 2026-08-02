import '../../../core/model/entidade_base.dart';

class ItemHistorico extends EntidadeBase {
  ItemHistorico({
    super.id,
    required this.idHistorico,
    required super.titulo,
    required this.tituloCategoria,
    required this.quantidade,
    required this.preco,
    required this.unidadeMedida,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  final int idHistorico;
  final String tituloCategoria;
  final int quantidade;
  final int preco;
  final String unidadeMedida;

  int get valorTotal => unidadeMedida == 'kg'
      ? (preco * quantidade / 1000).round()
      : preco * quantidade;
}
