abstract class EntidadeBase {
  int? id;
  String titulo;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool excluido;

  EntidadeBase({
    this.id,
    required this.titulo,
    this.dataCriacao,
    this.dataAlteracao,
    this.excluido = false,
  });
}
