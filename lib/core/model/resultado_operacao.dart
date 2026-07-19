class ResultadoOperacao<T> {
  final bool sucesso;
  final String? mensagem;
  final T? dados;

  const ResultadoOperacao({
    required this.sucesso,
    this.mensagem,
    this.dados,
  });
}
