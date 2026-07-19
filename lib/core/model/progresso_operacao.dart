class ProgressoOperacao {
  final int etapa;
  final int total;
  final String descricao;

  const ProgressoOperacao({
    required this.etapa,
    required this.total,
    required this.descricao,
  });
}

typedef AoProgredir = void Function(ProgressoOperacao progresso);
