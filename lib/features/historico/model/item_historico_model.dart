import '../../../core/constants/enums/prioridade.dart';
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
    this.prioridade = Prioridade.neutra,
    this.observacao,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  final int idHistorico;
  final String tituloCategoria;
  final int quantidade;
  final int preco;
  final String unidadeMedida;
  final Prioridade prioridade;
  final String? observacao;

  int get valorTotal => unidadeMedida == 'kg'
      ? (preco * quantidade / 1000).round()
      : preco * quantidade;

  ItemHistorico copia({
    String? titulo,
    int? quantidade,
    int? preco,
  }) {
    return ItemHistorico(
      id: id,
      idHistorico: idHistorico,
      titulo: titulo ?? this.titulo,
      tituloCategoria: tituloCategoria,
      quantidade: quantidade ?? this.quantidade,
      preco: preco ?? this.preco,
      unidadeMedida: unidadeMedida,
      prioridade: prioridade,
      observacao: observacao,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      excluido: excluido,
    );
  }
}
