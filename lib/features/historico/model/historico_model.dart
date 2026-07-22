import '../../../core/model/entidade_base.dart';

class Historico extends EntidadeBase {
  final String? descricao;
  final DateTime dataCompra;

  Historico({
    super.id,
    required super.titulo,
    this.descricao,
    required this.dataCompra,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });
}
