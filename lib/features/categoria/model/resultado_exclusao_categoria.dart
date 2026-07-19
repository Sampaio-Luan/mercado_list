import 'categoria_model.dart';

class ResultadoExclusaoCategoria {
  final Categoria categoriaPadrao;
  final int quantidadeItensMovidos;
  final DateTime dataAlteracao;

  const ResultadoExclusaoCategoria({
    required this.categoriaPadrao,
    required this.quantidadeItensMovidos,
    required this.dataAlteracao,
  });
}
